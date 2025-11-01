//
//  RosTopicSubscribe.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

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

    init(op: RosTopicOperation, topic: String, messageType: String, throttelRate: Int? = nil) {
        self.id = UUID().uuidString
        self.op = op
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

    func toJSONString() -> String? {
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
