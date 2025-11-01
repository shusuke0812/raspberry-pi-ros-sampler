//
//  RosBridgeClient.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

// Ref: https://github.com/RobotWebTools/roslibjs/blob/develop/src/core/Ros.js

protocol RosBridgeProtocol {
    func connect(ipAddress: String)
    func disconnect()
    func observeConnectionState() -> AsyncStream<WebSocketConnectionState>
    func subscribe(topic: RosTopicSubscribe, onMessage: @escaping (String) -> Void)
}

class RosBridgeClient: RosBridgeProtocol {
    private let websocketClient: WebSocketClient
    
    init() {
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

    func subscribe(topic: RosTopicSubscribe, onMessage: @escaping (String) -> Void) {
        guard let topicJsonString = topic.toJSONString(), topic.op == .subscribe else {
            assertionFailure()
            return
        }

        Task {
            try? await websocketClient.send(text: topicJsonString)
            for try await message in websocketClient.messages {
                if topic.isEqual(to: message) {
                    onMessage(message)
                }
            }
        }
    }
}
