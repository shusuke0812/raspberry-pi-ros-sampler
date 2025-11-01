//
//  RosTopicSubscribe.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

/// [Subscribe Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#334-subscribe)
struct RosTopicSubscribe: RosTopicProtocol, Codable {
    let id: String?
    let op: RosTopicOperation
    let topic: String
    let messageType: String
    let throttelRate: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case topic
        case messageType = "type"
        case throttelRate = "throttle_rate"
    }

    init(id: String? = nil, topic: String, messageType: String, throttelRate: Int? = nil) {
        self.id = id
        self.op = RosTopicOperation.subscribe
        self.topic = topic
        self.messageType = messageType
        self.throttelRate = throttelRate
    }

    func isEqual(to message: String) -> Bool {
        guard let rosTopic = Self.decodeMessage(from: message),
              rosTopic.topic == topic else {
            return false
        }

        if (rosTopic.id != id) {
            return false
        }

        return true
    }

    func toJsonString() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }

    static func decodeMessage(from jsonString: String) -> RosTopicSubscribe? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(RosTopicSubscribe.self, from: jsonData)
    }
}
