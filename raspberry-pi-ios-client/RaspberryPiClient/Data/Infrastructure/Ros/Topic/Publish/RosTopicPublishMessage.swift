//
//  RosTopicPublishMessage.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/9.
//

import Foundation

struct RosTopicPublishMessage<T: RosMessageProtocol>: Codable {
    let message: T

    enum CodingKeys: String, CodingKey {
        case message = "msg"
    }

    init(message: T) {
        self.message = message
    }
}
