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
    func subscribeHelloMessage(onMessage: @escaping (String) -> Void) {
        let topic = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/String")
        RosBridgeClient.shared.subscribe(topic: topic) { message in
            onMessage(message)
        }
    }
}
