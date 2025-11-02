//
//  RosBridgeConnectionRepository.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

class RosBridgeConnectionRepository {
    static let shared = RosBridgeConnectionRepository()

    private let rosBridgeClient: RosBridgeConnectionProtocol

    private init() {
        self.rosBridgeClient = RosBridgeClient()
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
