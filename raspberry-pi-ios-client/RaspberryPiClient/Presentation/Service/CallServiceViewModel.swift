//
//  CallServiceViewModel.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

protocol CallServiceViewModelProtocol: ObservableObject {
    func callSpawn()
}

class CallServiceViewModel: CallServiceViewModelProtocol {
    @Published private(set) var uiState: UiState = .standby

    enum UiState {
        case standby
        case loading
        case success(String)
        case failure(RosServiceError)
    }

    private let turtlesimRepository: TurtlesimRepositoryProtocol

    init(turtlesimRepository: TurtlesimRepositoryProtocol = TurtlesimRepository()) {
        self.turtlesimRepository = turtlesimRepository
    }

    func callSpawn() {
        turtlesimRepository.callSpawn(x: 2.0, y: 2.0, theta: 0.2)
    }
}
