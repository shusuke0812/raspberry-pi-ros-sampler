//
//  RosBridgeConnectionRepository.swift
//  RaspberryPiMouseiOS
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
    func connect(ipAddress: String) {
        RosBridgeClient.shared.connect(ipAddress: ipAddress)
    }

    func disconnect() {
        RosBridgeClient.shared.disconnect()
    }

    func observeConnectionState() -> AsyncStream<WebSocketConnectionState> {
        return RosBridgeClient.shared.observeConnectionState()
    }
}
