//
//  RosTopicUnsubscribe.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/8.
//

import Foundation

/// [Unsubscriber Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#335-unsubscribe)
struct RosTopicUnsubscribe: RosTopicUnsubscribeProtocol {
    let id: String?
    let op: RosTopicOperation
    let topic: String

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case topic
    }

    init(id: String? = nil, topic: String) {
        self.id = id
        self.op = RosTopicOperation.unsubscribe
        self.topic = topic
    }
}
