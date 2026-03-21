//
//  RosBridgeConnectionRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol RosBridgeConnectionRepositoryProtocol {
    func connect(ipAddress: String, connectionMode: ConnectionMode)
    func disconnect()
    func observeConnectionState() -> AsyncStream<WebSocketConnectionState>
    var activeMessageClient: RosBridgeMessageProtocol { get }
}

class RosBridgeConnectionRepository: RosBridgeConnectionRepositoryProtocol {
    private let rosBridgeClient: RosBridgeConnectionProtocol & RosBridgeMessageProtocol
    private let foxgloveBridgeClient: RosBridgeConnectionProtocol & RosBridgeMessageProtocol
    private var currentConnectionMode: ConnectionMode = .rosBridge

    init(
        rosBridgeClient: RosBridgeConnectionProtocol & RosBridgeMessageProtocol = RosBridgeClient.shared,
        foxgloveBridgeClient: RosBridgeConnectionProtocol & RosBridgeMessageProtocol = FoxgloveBridgeClient.shared
    ) {
        self.rosBridgeClient = rosBridgeClient
        self.foxgloveBridgeClient = foxgloveBridgeClient
    }

    private var activeConnectionClient: RosBridgeConnectionProtocol {
        switch currentConnectionMode {
        case .rosBridge: return rosBridgeClient
        case .foxgloveBridge: return foxgloveBridgeClient
        }
    }

    var activeMessageClient: RosBridgeMessageProtocol {
        switch currentConnectionMode {
        case .rosBridge: return rosBridgeClient
        case .foxgloveBridge: return foxgloveBridgeClient
        }
    }

    func connect(ipAddress: String, connectionMode: ConnectionMode) {
        currentConnectionMode = connectionMode
        activeConnectionClient.connect(ipAddress: ipAddress)
    }

    func disconnect() {
        activeConnectionClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        AsyncStream { continuation in
            let rosClient = rosBridgeClient
            let foxClient = foxgloveBridgeClient
            let task = Task {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        for await state in rosClient.observeConnectionState() {
                            continuation.yield(state)
                        }
                    }
                    group.addTask {
                        for await state in foxClient.observeConnectionState() {
                            continuation.yield(state)
                        }
                    }
                }
            }
            continuation.onTermination = { @Sendable _ in task.cancel() }
        }
    }
}
