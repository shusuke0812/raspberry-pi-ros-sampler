//
//  TopicMonitorScreenViewModel.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol TopicMonitorScreenViewModelProtocol: ObservableObject {
    var messages: [String] { get }
    func subscribeHelloMessage()
}

class TopicMonitorScreenViewModel: TopicMonitorScreenViewModelProtocol {
    @Published private(set) var messages: [String] = []

    private let helloMessageRepository: HelloMessageRepositoryProtocol

    init(helloMessageRepository: HelloMessageRepositoryProtocol = HelloMessageRepository()) {
        self.helloMessageRepository = helloMessageRepository
    }

    func subscribeHelloMessage() {
        helloMessageRepository.subscribeHelloMessage { [weak self] message in
            Task { @MainActor in
                self?.messages.append(message)
            }
        }
    }
}
