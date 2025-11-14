//
//  RosBridgeConnectionRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol RosBridgeConnectionRepositoryProtocol {
    func connect(ipAddress: String)
    func disconnect()
    func observeConnectionState() -> AsyncStream<WebSocketConnectionState>
}

class RosBridgeConnectionRepository: RosBridgeConnectionRepositoryProtocol {
    private let rosBridgeClient: RosBridgeConnectionProtocol

    init(rosBridgeClient: RosBridgeConnectionProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func connect(ipAddress: String) {
        rosBridgeClient.connect(ipAddress: ipAddress)
    }

    func disconnect() {
        rosBridgeClient.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        return rosBridgeClient.observeConnectionState()
    }
}
