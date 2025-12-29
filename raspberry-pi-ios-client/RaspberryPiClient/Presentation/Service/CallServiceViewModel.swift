//
//  CallServiceViewModel.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

protocol CallServiceViewModelProtocol: ObservableObject {
    var uiState: CallServiceViewModel.UiState { get }
    func spawnTurtle()
    func moveTurtle()
    func reset()
}

class CallServiceViewModel: CallServiceViewModelProtocol {
    @Published private(set) var uiState: UiState = .standby

    enum UiState {
        case standby
        case loading
        case success(String)
        case failure(RosServiceError)

        var title: String {
            switch self {
            case .standby:
                return "Standby"
            case .loading:
                return ""
            case .success(let message):
                return "Success\n\(message)"
            case .failure(let error):
                return error.description
            }
        }

        var joystickState: (isDisabled: Bool, opacity: Double) {
            switch self {
            case .standby, .loading, .failure:
                return (true, 0.6)
            case .success:
                return (false, 0.0)
            }
        }

        var isShowProgressView: Bool {
            switch self {
            case .loading:
                return true
            case .standby, .success, .failure:
                return false
            }
        }
    }

    private let turtlesimRepository: TurtlesimRepositoryProtocol

    init(turtlesimRepository: TurtlesimRepositoryProtocol = TurtlesimRepository()) {
        self.turtlesimRepository = turtlesimRepository
    }

    func spawnTurtle() {
        turtlesimRepository.spawnTurtle(x: 2.0, y: 2.0, theta: 0.2) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.uiState = .success("")
                case .failure(let error):
                    self.uiState = .failure(error)
                }
            }
        }
    }

    func moveTurtle() {
        turtlesimRepository.moveTurtle(x: 2.0, y: 0.0, theta: 1.0)
    }

    func reset() {
        turtlesimRepository.reset()
    }
}
