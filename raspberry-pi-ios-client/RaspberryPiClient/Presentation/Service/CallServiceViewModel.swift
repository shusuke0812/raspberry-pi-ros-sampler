//
//  CallServiceViewModel.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

protocol CallServiceViewModelProtocol: ObservableObject {
    var uiState: CallServiceViewModel.UiState { get }
    var knobPosition: KnobPosition { get set }
    func spawnTurtle()
    func reset()
    func changeKnobPosition(_ position: KnobPosition)
}

class CallServiceViewModel: CallServiceViewModelProtocol {
    @Published private(set) var uiState: UiState = .standby
    @Published var knobPosition: KnobPosition = KnobPosition(width: 0, height: 0)
    
    private var moveTimer: Timer?

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
    
    deinit {
        stopMoveTurtle()
    }

    func spawnTurtle() {
        turtlesimRepository.spawnTurtle(x: 2.0, y: 2.0, theta: 0.2) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.uiState = .success("")
                    self.startMoveTurtle()
                case .failure(let error):
                    self.uiState = .failure(error)
                }
            }
        }
    }

    func reset() {
        turtlesimRepository.reset()
    }

    func changeKnobPosition(_ position: KnobPosition) {
        knobPosition = position
        print(position.x, position.y, position.theta)
    }

    private func startMoveTurtle() {
        stopMoveTurtle()
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                self.turtlesimRepository.moveTurtle(x: self.knobPosition.y, y: self.knobPosition.x, radian: self.knobPosition.radian)
            }
        }
    }

    private func stopMoveTurtle() {
        moveTimer?.invalidate()
        moveTimer = nil
    }
}
