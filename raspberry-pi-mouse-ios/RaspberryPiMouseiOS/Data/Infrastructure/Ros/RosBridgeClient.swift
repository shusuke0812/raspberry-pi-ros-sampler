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
    func subscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void)
}

class RosBridgeClient: RosBridgeConnectionProtocol, RosBridgeSubscriptionProtocol {
    static let shared = RosBridgeClient()
    private let websocketClient: WebSocketClient
    
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

    func subscribe<T: RosMessageProtocol>(topic: RosTopicSubscribe<T>, onMessage: @escaping (Result<RosTopicPublish<T>, RosTopicError>) -> Void) {
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
}
