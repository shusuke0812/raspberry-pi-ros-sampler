//
//  HelloMessageRepository.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Foundation

protocol HelloMessageRepositoryProtocol {
    func subscribeHelloMessage(onMessage: @escaping (String) -> Void)
}

class HelloMessageRepository: HelloMessageRepositoryProtocol {
    private let rosBridgeClient: RosBridgeSubscriptionProtocol

    init(rosBridgeClient: RosBridgeSubscriptionProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func subscribeHelloMessage(onMessage: @escaping (String) -> Void) {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/String")
        rosBridgeClient.subscribe(topic: topic) { message in
            onMessage(message)
        }
    }
}
