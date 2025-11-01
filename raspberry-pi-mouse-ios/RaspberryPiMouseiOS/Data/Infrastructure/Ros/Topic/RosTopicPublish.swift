//
//  RosTopicPublish.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

struct RosTopicPublish: RosTopicProtocol, Codable {
    let id: String?
    let op: RosTopicOperation
    let topic: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case topic
        case message = "msg"
    }

    init(id: String? = nil, topic: String, message: RosMessage) {
        self.id = id
        self.op = RosTopicOperation.publish
        self.topic = topic
        self.message = message.toJsonString()
    }
}
