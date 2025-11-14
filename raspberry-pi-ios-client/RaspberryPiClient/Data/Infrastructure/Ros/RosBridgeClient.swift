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

class RosBridgeClient: RosBridgeConnectionProtocol, RosBridgeSubscriptionProtocol {
    static let shared = RosBridgeClient()
    private let websocketClient: WebSocketClient

    private var messageHandlers: [String: [(Result<String, RosTopicError>) -> Void]] = [:]
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
        messageHandlers.removeAll()
        websocketClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        return websocketClient.connectionStates
    }

    // MARK: - Publish / Subscribe

    func startSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        if messageHandlers[topic.topic] != nil {
            onMessage(.failure(.alreadySubscribed))
            return
        }
        subscribe(topic: topic, onMessage: onMessage)
    }

    func endSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>) {
        if messageHandlers[topic.topic] == nil {
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
        if messageHandlers[topic.topic] == nil {
            messageHandlers[topic.topic] = []
        }
        messageHandlers[topic.topic]?.append { result in
            switch result {
            case .success(let message):
                do {
                    if topic.isEqual(to: message) {
                        let result = try topic.decodeMessage(from: message)
                        onMessage(.success(result))
                    }
                } catch {
                    onMessage(.failure(error as! RosTopicError))
                }
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    private func deregisterSubscriber(topic: RosTopicUnsubscribe) {
        messageHandlers.removeValue(forKey: topic.topic)
    }

    private func observeReceivedMessage() {
        messageReceiverTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await message in websocketClient.messages {
                    guard let jsonData = message.data(using: .utf8),
                          let topicHeader = try? JSONDecoder().decode(RosTopicPublishHeader.self, from: jsonData) else {
                        continue
                    }
                    
                    if let handlers = messageHandlers[topicHeader.topic] {
                        for handler in handlers {
                            handler(.success(message))
                        }
                    }
                }
            } catch {
                for handlers in messageHandlers.values {
                    for handler in handlers {
                        handler(.failure(RosTopicError.failedReceiveMessage(reason: error)))
                    }
                }
            }
        }
    }
}
