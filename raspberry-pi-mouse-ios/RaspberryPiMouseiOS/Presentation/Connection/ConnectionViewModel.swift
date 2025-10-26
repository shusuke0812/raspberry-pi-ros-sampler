//
//  ConnectionViewModel.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/26.
//

import Combine
import Foundation

protocol ConnectionViewModelProtocol: ObservableObject {
    var ipAddress: String { get set }
    var connectionStatus: String { get }
    func connect()
}

class ConnectionViewModel: ConnectionViewModelProtocol {
    @Published private(set) var connectionStatus: String = "未接続"
    @Published var ipAddress: String = ""

    private let rosBridgeClient: RosBridgeClient
    private var observationTask: Task<Void, Never>?

    init() {
        rosBridgeClient = RosBridgeClient()
        startObservingConnectionStatus()
    }
    
    deinit {
        observationTask?.cancel()
    }
    
    private func startObservingConnectionStatus() {
        observationTask = Task { @MainActor in
            for await status in await rosBridgeClient.observeConnectionStatus() {
                switch status {
                case .connected:
                    connectionStatus = "接続中"
                case .disconnected:
                    connectionStatus = "切断"
                }
            }
        }
    }

    func connect() {
        rosBridgeClient.connect(ipAddress: ipAddress)
    }
}
