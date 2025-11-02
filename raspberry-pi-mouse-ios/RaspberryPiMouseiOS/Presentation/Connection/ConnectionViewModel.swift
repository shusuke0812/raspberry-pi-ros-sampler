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
    var connectionStatus: WebSocketConnectionState { get }
    func connect()
    func disconnect()
}

class ConnectionViewModel: ConnectionViewModelProtocol {
    @Published private(set) var connectionStatus = WebSocketConnectionState.ready
    @Published var ipAddress: String = ""

    private var observationTask: Task<Void, Never>?
    private let rosBridgeConnectionRepository: RosBridgeConnectionRepositoryProtocol

    init(rosBridgeConnectionRepository: RosBridgeConnectionRepositoryProtocol = RosBridgeConnectionRepository()) {
        self.rosBridgeConnectionRepository = rosBridgeConnectionRepository
        self.startObservingConnectionState()
    }
    
    deinit {
        observationTask?.cancel()
    }
    
    private func startObservingConnectionState() {
        observationTask = Task { @MainActor in
            for await state in rosBridgeConnectionRepository.observeConnectionState() {
                self.connectionStatus = state
            }
        }
    }

    func connect() {
        rosBridgeConnectionRepository.connect(ipAddress: ipAddress)
    }
    
    func disconnect() {
        rosBridgeConnectionRepository.disconnect()
    }
}

