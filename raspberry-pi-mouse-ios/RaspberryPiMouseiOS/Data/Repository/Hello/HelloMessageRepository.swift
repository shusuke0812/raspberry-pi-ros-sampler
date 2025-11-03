//
//  HelloMessageRepository.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol HelloMessageRepositoryProtocol {
    func subscribeHelloMessage(onMessage: @escaping (Result<HelloResponse, RosTopicError>) -> Void)
}

class HelloMessageRepository: HelloMessageRepositoryProtocol {
    private let rosBridgeClient: RosBridgeSubscriptionProtocol

    init(rosBridgeClient: RosBridgeSubscriptionProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func subscribeHelloMessage(onMessage: @escaping (Result<HelloResponse, RosTopicError>) -> Void) {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/String")
        rosBridgeClient.subscribe(topic: topic) { result in
            switch result {
            case .success(let message):
                onMessage(.success(message))
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }
}
