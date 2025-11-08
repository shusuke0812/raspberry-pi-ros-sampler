//
//  HelloTopicRepository.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol HelloTopicRepositoryProtocol {
    func subscribeHelloMessage(onMessage: @escaping (Result<HelloTopicResponse, RosTopicError>) -> Void)
    func unsubscribeHelloMessage()
}

class HelloTopicRepository: HelloTopicRepositoryProtocol {
    private let rosBridgeClient: RosBridgeSubscriptionProtocol

    init(rosBridgeClient: RosBridgeSubscriptionProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func subscribeHelloMessage(onMessage: @escaping (Result<HelloTopicResponse, RosTopicError>) -> Void) {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/String")
        rosBridgeClient.startSubscribe(topic: topic) { result in
            switch result {
            case .success(let message):
                onMessage(.success(message))
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    func unsubscribeHelloMessage() {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/String")
        rosBridgeClient.endSubscribe(topic: topic)
    }
}
