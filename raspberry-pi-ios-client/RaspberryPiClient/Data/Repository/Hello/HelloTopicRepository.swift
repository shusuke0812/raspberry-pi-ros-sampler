//
//  HelloTopicRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol HelloTopicRepositoryProtocol {
    func subscribeHello(onMessage: @escaping (Result<HelloTopicResponse, RosTopicError>) -> Void)
    func unsubscribeHello()
    func subscribeHelloSignal(onMessage: @escaping (Result<HelloSignalTopicResponse, RosTopicError>) -> Void)
    func unsubscribeHelloSignal()
}

class HelloTopicRepository: HelloTopicRepositoryProtocol {
    private let rosBridgeClient: RosBridgeSubscriptionProtocol

    init(rosBridgeClient: RosBridgeSubscriptionProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func subscribeHello(onMessage: @escaping (Result<HelloTopicResponse, RosTopicError>) -> Void) {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/msg/String")
        rosBridgeClient.startSubscribe(topic: topic) { result in
            switch result {
            case .success(let message):
                onMessage(.success(message))
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    func unsubscribeHello() {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/msg/String")
        rosBridgeClient.endSubscribe(topic: topic)
    }

    func subscribeHelloSignal(onMessage: @escaping (Result<HelloSignalTopicResponse, RosTopicError>) -> Void) {
        let topic = RosTopicSubscribe<Int8Message>(topic: "/hello_signal", messageType: "std_msgs/msg/Int8")
        rosBridgeClient.startSubscribe(topic: topic) { result in
            switch result {
            case .success(let message):
                onMessage(.success(message))
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    func unsubscribeHelloSignal() {
        let topic = RosTopicSubscribe<Int8Message>(topic: "/hello_signal", messageType: "std_msgs/msg/Int8")
        rosBridgeClient.endSubscribe(topic: topic)
    }
}
