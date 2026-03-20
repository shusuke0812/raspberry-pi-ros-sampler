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
class FoxgloveBridgeClient: RosBridgeConnectionProtocol {
    static let shared = FoxgloveBridgeClient()

    private let websocketClient: WebSocketClient
    private var messageReceiverTask: Task<Void, Never>?

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

    private let mapQueue = DispatchQueue(label: "jp.shusuke.ota.FoxgloveBridgeClient.mapQueue")

    private init() {
        websocketClient = WebSocketClient()
        observeReceivedMessage()
    }

    // MARK: - RosBridgeConnectionProtocol

    func connect(ipAddress: String) {
        let url = WebSocketUrl.foxglove(ipAddress: ipAddress)
        websocketClient.connect(webSocketUrl: url, protocols: ["foxglove.websocket.v1"])
    }

    func disconnect() {
        messageReceiverTask?.cancel()
        messageReceiverTask = nil
        clearMaps()
        websocketClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        websocketClient.connectionStates
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
    }

    private func observeReceivedMessage() {
        messageReceiverTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await message in websocketClient.messages {
                    self.handleJsonMessage(message)
                }
            } catch {
                // 接続切断時のエラーは observeConnectionState で通知される
            }
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

        case .status, .serviceCallFailure, .other:
            break
        }
    }
}
