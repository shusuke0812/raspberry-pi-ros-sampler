//
//  RosTopicPublish.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

/// [Publish Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#333-publish--publish-)
struct RosTopicPublish<T: RosMessageProtocol>: RosTopicPublishProtocol {
    let id: String?
    let op: RosTopicOperation
    let topic: String
    let message: T

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case topic
        case message = "msg"
    }

    init(id: String? = nil, topic: String, message: T) {
        self.id = id
        self.op = RosTopicOperation.publish
        self.topic = topic
        self.message = message
    }
}
