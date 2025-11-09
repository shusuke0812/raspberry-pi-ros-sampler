//
//  RosTopicPublish.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

/// [Publish Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#333-publish--publish-)
struct RosTopicPublish<T: RosMessageProtocol>: Codable {
    let header: RosTopicPublishHeader
    let message: T

    init(id: String? = nil, topic: String, message: T) {
        self.header = RosTopicPublishHeader(
            id: id,
            op: .publish,
            topic: topic
        )
        self.message = message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // header
        let id = try container.decodeIfPresent(String.self, forKey: .id)
        let op = try container.decode(RosBridgeMessageOperation.self, forKey: .op)
        let topic = try container.decode(String.self, forKey: .topic)
        self.header = RosTopicPublishHeader(id: id, op: op, topic: topic)
        
        // message
        self.message = try container.decode(T.self, forKey: .message)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // header
        try container.encodeIfPresent(header.id, forKey: .id)
        try container.encode(header.op, forKey: .op)
        try container.encode(header.topic, forKey: .topic)
        
        // message
        try container.encode(message, forKey: .message)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case op
        case topic
        case message = "msg"
    }
}
