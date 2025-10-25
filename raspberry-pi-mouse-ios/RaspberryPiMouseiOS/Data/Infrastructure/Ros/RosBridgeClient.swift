//
//  RosBridgeClient.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

// Ref: https://github.com/RobotWebTools/roslibjs/blob/develop/src/core/Ros.js

class RosBridgeClient {
    private let websocketClient: WebSocketClient
    private var connectionStatus: [CheckedContinuation<RosBridgeConnectionStatus, Never>] = []

    init(urlString: String) {
        websocketClient = WebSocketClient(urlString: urlString)
        websocketClient.delegate = self
    }

    func connect() {
        websocketClient.connect()
    }

    func disconnect() {
        websocketClient.disconnect()
    }

    func observeConnectionStatus() async -> AsyncStream<RosBridgeConnectionStatus> {
        return AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    let status = await withCheckedContinuation { cont in
                        connectionStatus.append(cont)
                    }
                    continuation.yield(status)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

// MARK: - WebSocketClientDelegate
extension RosBridgeClient: WebSocketClientDelegate {
    func webSocketClient(didConnect client: WebSocketClient) {
        connectionStatus.forEach { continuation in
            continuation.resume(returning: .connected)
        }
        connectionStatus.removeAll()
    }
    
    func webSocketClient(didDisconnect client: WebSocketClient) {
        connectionStatus.forEach { continuation in
            continuation.resume(returning: .disconnected)
        }
        connectionStatus.removeAll()
    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveText text: String) {

    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveDat data: Data) {

    }
    
    func webSocketClient(_ client: WebSocketClient, didReceiveError error: any Error) {

    }
    
    func webSocketClient(_ client: WebSocketClient, failedSendingMessageError error: (any Error)?) {

    }
}
