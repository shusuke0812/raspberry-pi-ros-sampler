//
//  RosBridgeClient.swift
//  RaspberryPiMouseiOS
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
    func endSubscribere<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>)
}

class RosBridgeClient: RosBridgeConnectionProtocol, RosBridgeSubscriptionProtocol {
    static let shared = RosBridgeClient()
    private let websocketClient: WebSocketClient

    private var subscribers: [any RosTopicSubscribeProtocol] = []

    private init() {
        websocketClient = WebSocketClient()
    }

    // MARK: - Connection

    func connect(ipAddress: String) {
        websocketClient.connect(webSocketUrl: WebSocketUrl(ipAddress: ipAddress))
    }

    func disconnect() {
        websocketClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        return websocketClient.connectionStates
    }

    // MARK: - Publish / Subscribe

    func startSubscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        do {
            try registerSubscriber(topic: topic)
        } catch {
            onMessage(.failure(error as! RosTopicError))
            return
        }

        subscribe(topic: topic, onMessage: onMessage)
    }

    func endSubscribere<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>) {
        let result = deregisterSubscriber(topic: topic)
        if (result) {
            let topic = RosTopicUnsubscribe(id: topic.id, topic: topic.topic)
            unsubscribe(topic: topic)
        }
    }

    private func subscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
        guard let topicJsonString = topic.toJsonString(), topic.op == .subscribe else {
            assertionFailure()
            return
        }

        Task {
            try? await websocketClient.send(text: topicJsonString)
            for try await message in websocketClient.messages {
                do {
                    let receivedTopic = try topic.decodeMessage(from: message)
                    if topic.isEqual(to: receivedTopic) {
                        onMessage(.success(receivedTopic))
                    }
                } catch {
                    onMessage(.failure(error as! RosTopicError))
                }
            }
        }
    }

    private func unsubscribe(topic: RosTopicUnsubscribe) {
        guard let topicJsonString = topic.toJsonString(), topic.op == .unsubscribe else {
            assertionFailure()
            return
        }

        Task {
            try? await websocketClient.send(text: topicJsonString)
        }
    }

    private func registerSubscriber<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>) throws {
        if (subscribers.first(where: {$0.topic == topic.topic})) != nil {
            throw RosTopicError.alreadySubscribed
        }
        subscribers.append(topic)
    }

    private func deregisterSubscriber<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>) -> Bool {
        if (subscribers.first(where: {$0.topic == topic.topic})) == nil {
            return false
        }
        subscribers.removeAll(where: {$0.topic == topic.topic})
        return true
    }
}
