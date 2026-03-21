//
//  FoxgloveBridgeClient.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/21.
//

import Foundation

/// Foxglove Bridge 用クライアント
/// serverInfo, advertise, advertiseServices の受信とマップ保持を行う
/// Ref: https://docs.foxglove.dev/sdk
class FoxgloveBridgeClient: RosBridgeConnectionProtocol, RosBridgeMessageProtocol {
    static let shared = FoxgloveBridgeClient()

    private let websocketClient: WebSocketClient
    private var jsonMessageReceiverTask: Task<Void, Never>?
    private var binaryMessageReceiverTask: Task<Void, Never>?

    /// サーバー情報（接続確立後に受信）
    private(set) var serverInfo: FoxgloveServerInfo?

    /// トピック名 → channelId のマップ（subscribe 時に使用）
    private(set) var topicToChannelIdMap: [String: UInt32] = [:]

    /// channelId → トピック名 のマップ（unadvertise 時に使用）
    private(set) var channelIdToTopicMap: [UInt32: String] = [:]

    /// サービス名 → serviceId のマップ（callService 時に使用）
    private(set) var serviceNameToIdMap: [String: UInt32] = [:]

    /// serviceId → サービス名 のマップ（unadvertiseServices 時に使用）
    private(set) var serviceIdToNameMap: [UInt32: String] = [:]

    /// クライアント publish 用: トピック名 → channelId のマップ（Client Advertise で登録したチャンネル）
    private var clientPublishTopicToChannelId: [String: UInt32] = [:]
    private var nextClientChannelId: UInt32 = 1
    private let clientPublishQueue = DispatchQueue(label: "jp.shusuke.ota.FoxgloveBridgeClient.clientPublishQueue")

    private let mapQueue = DispatchQueue(label: "jp.shusuke.ota.FoxgloveBridgeClient.mapQueue")

    /// トピック → 購読情報（subscriptionId とデコード・通知用クロージャ）
    private var topicToSubscriptionInfo: [String: (subscriptionId: UInt32, info: FoxgloveSubscriptionInfo)] = [:]
    /// subscriptionId → トピック名（Message Data 受信時のルックアップ用）
    private var subscriptionIdToTopic: [UInt32: String] = [:]
    private var nextSubscriptionId: UInt32 = 1
    private let subscriptionQueue = DispatchQueue(label: "jp.shusuke.ota.FoxgloveBridgeClient.subscriptionQueue")

    /// callId → サービス呼び出しハンドラ（Service Call Response 受信時に使用）
    /// 成功時は (Data, serviceName)、失敗時は RosServiceError を渡す
    private var callIdToHandler: [UInt32: (Result<(Data, String), RosServiceError>) -> Void] = [:]
    private var nextCallId: UInt32 = 1
    private let serviceCallQueue = DispatchQueue(label: "jp.shusuke.ota.FoxgloveBridgeClient.serviceCallQueue")

    private init() {
        websocketClient = WebSocketClient()
        observeReceivedMessage()
    }

    // MARK: - RosBridgeConnectionProtocol

    func connect(ipAddress: String) {
        let url = WebSocketUrl.foxglove(ipAddress: ipAddress)
        websocketClient.connect(webSocketUrl: url)
    }

    func disconnect() {
        jsonMessageReceiverTask?.cancel()
        jsonMessageReceiverTask = nil
        binaryMessageReceiverTask?.cancel()
        binaryMessageReceiverTask = nil
        clearMaps()
        clearSubscriptions()
        clearServiceCallHandlers()
        websocketClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        websocketClient.connectionStates
    }

    // MARK: - RosBridgeMessageProtocol

    func publish<T: RosMessageProtocol>(topic: RosTopicPublish<T>) {
        guard mapQueue.sync(execute: { serverInfo?.supportsClientPublish }) == true else {
            return
        }
        guard mapQueue.sync(execute: { serverInfo?.supportsJsonEncoding }) == true else {
            return
        }

        let (channelId, needsAdvertise) = clientPublishQueue.sync { () -> (UInt32, Bool) in
            if let existing = clientPublishTopicToChannelId[topic.header.topic] {
                return (existing, false)
            }
            let id = nextClientChannelId
            nextClientChannelId += 1
            clientPublishTopicToChannelId[topic.header.topic] = id
            return (id, true)
        }

        guard let payloadData = try? JSONEncoder().encode(topic.message) else {
            return
        }

        let binaryData = FoxgloveBinaryMessageEncoder.encodeClientMessageData(channelId: channelId, payload: payloadData)

        Task {
            if needsAdvertise {
                await sendClientAdvertise(topic: topic.header.topic, channelId: channelId, schemaName: T.rosSchemaName)
            }
            try? await websocketClient.send(data: binaryData)
        }
    }

    private func sendClientAdvertise(topic: String, channelId: UInt32, schemaName: String) async {
        let channel = FoxgloveClientAdvertiseChannel(
            id: channelId,
            topic: topic,
            encoding: "json",
            schemaName: schemaName,
            schema: nil,
            schemaEncoding: nil
        )
        let advertise = FoxgloveClientAdvertise(channels: [channel])
        guard let jsonString = advertise.toJsonString() else {
            return
        }
        try? await websocketClient.send(text: jsonString)
    }

    func startSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        subscriptionQueue.sync {
            if topicToSubscriptionInfo[topic.topic] != nil {
                onMessage(.failure(.alreadySubscribed))
                return
            }
        }

        guard let channelId = channelId(forTopic: topic.topic) else {
            onMessage(.failure(.channelNotFound))
            return
        }

        let subscriptionId = subscriptionQueue.sync { () -> UInt32 in
            let id = nextSubscriptionId
            nextSubscriptionId += 1
            return id
        }

        let subscribe = FoxgloveSubscribe(subscriptions: [
            FoxgloveSubscribeSubscription(id: subscriptionId, channelId: channelId)
        ])
        guard let jsonString = subscribe.toJsonString() else {
            onMessage(.failure(.failedDecodeMessageToRosPublish(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode subscribe"]))))
            return
        }

        let info = FoxgloveSubscriptionInfo(topic: topic.topic) { result in
            switch result {
            case .success(let payload):
                do {
                    let decoded = try topic.decodeMessageFromPayload(payload)
                    onMessage(.success(decoded))
                } catch {
                    onMessage(.failure(.failedDecodeMessageToRosPublish(reason: error)))
                }
            case .failure(let error):
                onMessage(.failure(.failedReceiveMessage(reason: error)))
            }
        }

        subscriptionQueue.sync {
            topicToSubscriptionInfo[topic.topic] = (subscriptionId, info)
            subscriptionIdToTopic[subscriptionId] = topic.topic
        }

        Task {
            try? await websocketClient.send(text: jsonString)
        }
    }

    func endSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>) {
        guard let (subscriptionId, _) = subscriptionQueue.sync(execute: { topicToSubscriptionInfo[topic.topic] }) else {
            return
        }

        let unsubscribe = FoxgloveUnsubscribe(subscriptionIds: [subscriptionId])
        guard let jsonString = unsubscribe.toJsonString() else {
            return
        }

        subscriptionQueue.sync {
            topicToSubscriptionInfo.removeValue(forKey: topic.topic)
            subscriptionIdToTopic.removeValue(forKey: subscriptionId)
        }

        Task {
            try? await websocketClient.send(text: jsonString)
        }
    }

    func callService<T: RosCallServiceProtocol>(service: T, onMessage: @escaping (Result<T.Response, RosServiceError>) -> Void) {
        guard mapQueue.sync(execute: { serverInfo?.supportsServices }) == true else {
            onMessage(.failure(.failedReceiveMessage(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server does not support services"]))))
            return
        }
        guard mapQueue.sync(execute: { serverInfo?.supportsJsonEncoding }) == true else {
            onMessage(.failure(.failedReceiveMessage(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server does not support JSON encoding"]))))
            return
        }

        guard let serviceId = serviceId(forServiceName: service.header.service) else {
            onMessage(.failure(.failedReceiveMessage(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service '\(service.header.service)' not found in advertiseServices"]))))
            return
        }

        let payloadData: Data
        if let arg = service.arg {
            guard let encoded = try? JSONEncoder().encode(arg) else {
                onMessage(.failure(.failedReceiveMessage(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode service request"]))))
                return
            }
            payloadData = encoded
        } else {
            payloadData = "{}".data(using: .utf8) ?? Data()
        }

        let callId = serviceCallQueue.sync { () -> UInt32 in
            let id = nextCallId
            nextCallId += 1
            return id
        }

        let handler: (Result<(Data, String), RosServiceError>) -> Void = { result in
            switch result {
            case .success((let data, let serviceName)):
                do {
                    let response = try Self.decodeServiceResponse(T.Response.self, from: data, serviceName: serviceName)
                    onMessage(.success(response))
                } catch {
                    onMessage(.failure(.failedDecodeMessage(reason: error)))
                }
            case .failure(let error):
                onMessage(.failure(error))
            }
        }

        serviceCallQueue.sync {
            callIdToHandler[callId] = handler
        }

        let binaryData = FoxgloveBinaryMessageEncoder.encodeServiceCallRequest(
            serviceId: serviceId,
            callId: callId,
            encoding: "json",
            payload: payloadData
        )

        Task {
            try? await websocketClient.send(data: binaryData)
        }
    }

    /// Foxglove の Service Call Response ペイロード（values のみの JSON）を RosServiceResponse にデコードする
    private static func decodeServiceResponse<R: RosServiceResponseProtocol>(_ type: R.Type, from data: Data, serviceName: String) throws -> R {
        let payloadObj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        let wrappedDict: [String: Any] = [
            "op": "service_response",
            "service": serviceName,
            "result": true,
            "values": payloadObj
        ]
        let wrappedData = try JSONSerialization.data(withJSONObject: wrappedDict)
        return try JSONDecoder().decode(type, from: wrappedData)
    }

    // MARK: - Map Access (for subscribe, publish, callService)

    func channelId(forTopic topic: String) -> UInt32? {
        mapQueue.sync { topicToChannelIdMap[topic] }
    }

    func serviceId(forServiceName name: String) -> UInt32? {
        mapQueue.sync { serviceNameToIdMap[name] }
    }

    // MARK: - Private

    private func clearMaps() {
        mapQueue.sync {
            serverInfo = nil
            topicToChannelIdMap.removeAll()
            channelIdToTopicMap.removeAll()
            serviceNameToIdMap.removeAll()
            serviceIdToNameMap.removeAll()
        }
        clientPublishQueue.sync {
            clientPublishTopicToChannelId.removeAll()
            nextClientChannelId = 1
        }
    }

    private func clearSubscriptions() {
        subscriptionQueue.sync {
            topicToSubscriptionInfo.removeAll()
            subscriptionIdToTopic.removeAll()
        }
    }

    private func clearServiceCallHandlers() {
        let handlers = serviceCallQueue.sync { () -> [(Result<(Data, String), RosServiceError>) -> Void] in
            let h = callIdToHandler.values.map { $0 }
            callIdToHandler.removeAll()
            nextCallId = 1
            return h
        }
        let error = RosServiceError.failedReceiveMessage(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Connection closed"]))
        for handler in handlers {
            handler(.failure(error))
        }
    }

    private func observeReceivedMessage() {
        jsonMessageReceiverTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await message in websocketClient.messages {
                    self.handleJsonMessage(message)
                }
            } catch {
                // 接続切断時のエラーは observeConnectionState で通知される
            }
        }

        binaryMessageReceiverTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await data in websocketClient.binaryMessages {
                    self.handleBinaryMessage(data)
                }
            } catch {
                self.notifySubscribersOfError(error)
            }
        }
    }

    private func handleBinaryMessage(_ data: Data) {
        let parsed = FoxgloveBinaryMessageParser.parseServerMessage(data)

        switch parsed {
        case .messageData(let subscriptionId, _, let payload):
            guard let topic = subscriptionQueue.sync(execute: { subscriptionIdToTopic[subscriptionId] }),
                  let (_, info) = subscriptionQueue.sync(execute: { topicToSubscriptionInfo[topic] }) else {
                return
            }
            info.onResult(.success(payload))

        case .serviceCallResponse(let responseServiceId, let callId, _, let payload):
            let handler = serviceCallQueue.sync { () -> ((Result<(Data, String), RosServiceError>) -> Void)? in
                let h = callIdToHandler[callId]
                callIdToHandler.removeValue(forKey: callId)
                return h
            }
            guard let handler else { return }
            let serviceName = mapQueue.sync { serviceIdToNameMap[responseServiceId] } ?? ""
            handler(.success((payload, serviceName)))

        case .time, .fetchAssetResponse, .unknown:
            break
        }
    }

    private func notifySubscribersOfError(_ error: Error) {
        let infos = subscriptionQueue.sync { topicToSubscriptionInfo.map { $0.value.info } }
        for info in infos {
            info.onResult(.failure(error))
        }
    }

    private func handleJsonMessage(_ jsonString: String) {
        guard let parsed = FoxgloveJsonMessageParser.parseServerMessage(jsonString) else {
            return
        }

        switch parsed {
        case .serverInfo(let info):
            mapQueue.sync {
                serverInfo = info
            }

        case .advertise(let advertise):
            let newMap = advertise.topicToChannelIdMap()
            mapQueue.sync {
                for (topic, channelId) in newMap {
                    topicToChannelIdMap[topic] = channelId
                    channelIdToTopicMap[channelId] = topic
                }
            }

        case .unadvertise(let channelIds):
            mapQueue.sync {
                for channelId in channelIds {
                    if let topic = channelIdToTopicMap[channelId] {
                        topicToChannelIdMap.removeValue(forKey: topic)
                        channelIdToTopicMap.removeValue(forKey: channelId)
                    }
                }
            }

        case .advertiseServices(let services):
            let newMap = services.serviceNameToIdMap()
            mapQueue.sync {
                for (name, serviceId) in newMap {
                    serviceNameToIdMap[name] = serviceId
                    serviceIdToNameMap[serviceId] = name
                }
            }

        case .unadvertiseServices(let serviceIds):
            mapQueue.sync {
                for serviceId in serviceIds {
                    if let name = serviceIdToNameMap[serviceId] {
                        serviceNameToIdMap.removeValue(forKey: name)
                        serviceIdToNameMap.removeValue(forKey: serviceId)
                    }
                }
            }

        case .serviceCallFailure(_, let callId, let message):
            let handler = serviceCallQueue.sync { () -> ((Result<(Data, String), RosServiceError>) -> Void)? in
                let h = callIdToHandler[callId]
                callIdToHandler.removeValue(forKey: callId)
                return h
            }
            handler?(.failure(.failedReceiveMessage(reason: NSError(domain: "FoxgloveBridgeClient", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))))

        case .status, .other:
            break
        }
    }
}

/// 購読情報（subscriptionId とデコード・通知用クロージャ）
private struct FoxgloveSubscriptionInfo {
    let topic: String
    let onResult: (Result<Data, Error>) -> Void
}
