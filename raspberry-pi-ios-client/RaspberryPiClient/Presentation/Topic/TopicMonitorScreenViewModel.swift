//
//  TopicMonitorScreenViewModel.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol TopicMonitorScreenViewModelProtocol: ObservableObject {
    var uiState: TopicMonitorScreenViewModel.UiState { get }
    var isErrorPresented: Bool { get set }
    func subscribeHelloMessage()
    func unsubscribeHelloMessage()
    func subscribeHelloSignal()
    func unsubscribeHelloSignal()
    func hideErrorAlert()
}

class TopicMonitorScreenViewModel: TopicMonitorScreenViewModelProtocol {
    @Published private(set) var uiState: UiState = .standby
    @Published var isErrorPresented = false
    private var messages: [String] = []

    enum UiState {
        case standby
        case loading
        case success([String])
        case failure(RosTopicError)

        var title: String {
            switch self {
            case .standby:
                return "Not found messages"
            case .loading, .success:
                return ""
            case .failure(let error):
                return error.description
            }
        }
    }

    private let helloTopicRepository: HelloTopicRepositoryProtocol

    init(helloTopicRepository: HelloTopicRepositoryProtocol = HelloTopicRepository()) {
        self.helloTopicRepository = helloTopicRepository
    }

    func hideErrorAlert() {
        isErrorPresented = false
        if messages.isEmpty {
            uiState = .standby
        }
    }

    func subscribeHelloMessage() {
        self.uiState = .loading
        helloTopicRepository.subscribeHello { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let hello):
                    self.messages.insert("\(self.messages.count)." + hello.message.data, at: 0)
                    self.uiState = .success(self.messages)
                case .failure(let error):
                    self.uiState = .failure(error)
                    self.isErrorPresented = true
                }
            }
        }
    }

    func unsubscribeHelloMessage() {
        messages.removeAll()
        helloTopicRepository.unsubscribeHello()
    }

    func subscribeHelloSignal() {
        self.uiState = .loading
        helloTopicRepository.subscribeHelloSignal { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let helloSignal):
                    self.messages.insert("\(self.messages.count)." + "\(helloSignal.message.data)", at: 0)
                    self.uiState = .success(self.messages)
                case .failure(let error):
                    self.uiState = .failure(error)
                    self.isErrorPresented = true
                }
            }
        }
    }

    func unsubscribeHelloSignal() {
        messages.removeAll()
        helloTopicRepository.unsubscribeHelloSignal()
    }
}
