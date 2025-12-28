//
//  RosBridgeClient.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

// Ref: https://github.com/RobotWebTools/roslibjs/blob/develop/src/core/Ros.js

protocol RosBridgeConnectionProtocol {
    func connect(ipAddress: String)
    func disconnect()
    func observeConnectionState() -> AsyncStream<WebSocketConnectionState>
}

protocol RosBridgeSubscriptionProtocol {
    func startSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void)
    func endSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>)
}

protocol RosBridgeServiceProtocol {
    func callService<T: RosCallServiceProtocol>(service: T, onMessage: @escaping (Result<T.Response, RosServiceError>) -> Void)
}

class RosBridgeClient: RosBridgeConnectionProtocol, RosBridgeSubscriptionProtocol, RosBridgeServiceProtocol {
    static let shared = RosBridgeClient()
    private let websocketClient: WebSocketClient

    private var topicMessageHandlers: [String: [(Result<String, RosTopicError>) -> Void]] = [:]
    private var serviceMessageHandlers: [String: [(Result<String, RosServiceError>) -> Void]] = [:]
    private var messageReceiverTask: Task<Void, Never>?

    private init() {
        websocketClient = WebSocketClient()
        observeReceivedMessage()
    }

    // MARK: - Connection

    func connect(ipAddress: String) {
        websocketClient.connect(webSocketUrl: WebSocketUrl(ipAddress: ipAddress))
    }

    func disconnect() {
        messageReceiverTask?.cancel()
        messageReceiverTask = nil
        topicMessageHandlers.removeAll()
        websocketClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        return websocketClient.connectionStates
    }

    // MARK: - Publish / Subscribe

    func startSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        if topicMessageHandlers[topic.topic] != nil {
            onMessage(.failure(.alreadySubscribed))
            return
        }
        subscribe(topic: topic, onMessage: onMessage)
    }

    func endSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>) {
        if topicMessageHandlers[topic.topic] == nil {
            return
        }
        let unsubscribeTopic = RosTopicUnsubscribe(id: topic.id, topic: topic.topic)
        unsubscribe(topic: unsubscribeTopic)
    }

    private func subscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        guard let topicJsonString = topic.toJsonString(), topic.op == .subscribe else {
            assertionFailure()
            return
        }

        Task {
            try? await websocketClient.send(text: topicJsonString)
        }
        
        registerSubscriber(topic: topic, onMessage: onMessage)
    }

    private func unsubscribe(topic: RosTopicUnsubscribe) {
        guard let topicJsonString = topic.toJsonString(), topic.op == .unsubscribe else {
            assertionFailure()
            return
        }

        Task {
            try? await websocketClient.send(text: topicJsonString)
        }

        deregisterSubscriber(topic: topic)
    }

    private func registerSubscriber<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        topicMessageHandlers[topic.topic] = []
        topicMessageHandlers[topic.topic]?.append { result in
            switch result {
            case .success(let message):
                guard topic.isEqual(to: message) else {
                    return
                }
                do {
                    let result = try topic.decodeMessage(from: message)
                    onMessage(.success(result))
                } catch {
                    onMessage(.failure(error as! RosTopicError))
                }
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    private func deregisterSubscriber(topic: RosTopicUnsubscribe) {
        topicMessageHandlers.removeValue(forKey: topic.topic)
    }

    private func handleTopic(message: String, jsonData: Data) {
        do {
            let header = try JSONDecoder().decode(RosTopicPublishHeader.self, from: jsonData)
            if let handlers = topicMessageHandlers[header.topic] {
                for handler in handlers {
                    handler(.success(message))
                }
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    // MARK: - Service

    func callService<T: RosCallServiceProtocol>(service: T, onMessage: @escaping (Result<T.Response, RosServiceError>) -> Void) {
        if (serviceMessageHandlers[service.header.service] != nil) {
            onMessage(.failure(.alreadyCalling))
            return
        }
        call(service: service, onMessage: onMessage)
    }

    private func call<T: RosCallServiceProtocol>(service: T, onMessage: @escaping (Result<T.Response, RosServiceError>) -> Void) {
        guard let requestJsonString = service.toJsonString(), service.header.op == .callService else {
            assertionFailure()
            return
        }
        Task {
            try? await websocketClient.send(text: requestJsonString)
        }
        registerService(service: service, onMessage: onMessage)
    }

    private func registerService<T: RosCallServiceProtocol>(service: T, onMessage: @escaping (Result<T.Response , RosServiceError>) -> Void) {
        serviceMessageHandlers[service.header.service] = []
        serviceMessageHandlers[service.header.service]?.append { result in
            switch result {
            case .success(let message):
                guard service.isEqual(to: message) else {
                    return
                }
                do {
                    let jsonData = message.data(using: .utf8)!
                    let response = try JSONDecoder().decode(T.Response.self, from: jsonData)
                    onMessage(.success(response))
                } catch {
                    onMessage(.failure(.failedDecodeMessage(reason: error)))
                }
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    private func handleService(message: String, jsonData: Data) {
        do {
            let header = try JSONDecoder().decode(RosServiceResponseHeader.self, from: jsonData)
            if let handlers = serviceMessageHandlers[header.service] {
                for handler in handlers {
                    handler(.success(message))
                }
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    // MARK: - Common

    private func observeReceivedMessage() {
        messageReceiverTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await message in websocketClient.messages {
                    guard let jsonData = message.data(using: .utf8),
                          let header = try? JSONDecoder().decode(HandleRosBridgeMessageResponse.self, from: jsonData) else {
                        continue
                    }

                    if let topic = HandleRosBridgeMessageOperation(header.op) {
                        switch topic {
                        case .publish:
                            handleTopic(message: message, jsonData: jsonData)
                        case .serviceResponse:
                            handleService(message: message, jsonData: jsonData)
                        }
                    }
                }
            } catch {
                for topicMessageHandlers in topicMessageHandlers.values {
                    for handler in topicMessageHandlers {
                        handler(.failure(RosTopicError.failedReceiveMessage(reason: error)))
                    }
                }
                for serviceMessageHandlers in serviceMessageHandlers.values {
                    for handler in serviceMessageHandlers {
                        handler(.failure(RosServiceError.failedReceiveMessage(reason: error)))
                    }
                }
            }
        }
    }
}
