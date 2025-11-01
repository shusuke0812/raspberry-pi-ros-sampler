//
//  RosTopic.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

struct RosTopic: Codable {
    let id: String
    let op: RosTopicOperation
    let name: String
    let messageType: String
    let throttelRate: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case name = "topic"
        case messageType = "type"
        case throttelRate = "throttle_rate"
    }

    init(op: RosTopicOperation, name: String, messageType: String, throttelRate: Int? = nil) {
        self.id = UUID().uuidString
        self.op = op
        self.name = name
        self.messageType = messageType
        self.throttelRate = throttelRate
    }

    func isEqual(to message: String) -> Bool {
        guard let rosTopic = Self.decodeMessage(from: message),
              rosTopic.name == name else {
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

    static func decodeMessage(from jsonString: String) -> RosTopic? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(RosTopic.self, from: jsonData)
    }
}
