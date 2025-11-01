//
//  RosTopic.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

struct RosTopic: Codable {
    let id: String
    let op: Operation
    let name: String
    let messageType: String
    let throttelRate: Int?

    enum Operation: String, Codable {
        case subscribe
        case publish
        case unsubscribe
    }

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case name = "topic"
        case messageType = "type"
        case throttelRate = "throttle_rate"
    }

    init(op: Operation, name: String, messageType: String, throttelRate: Int? = nil) {
        self.id = UUID().uuidString
        self.op = op
        self.name = name
        self.messageType = messageType
        self.throttelRate = throttelRate
    }

    func isEqual(to message: String) -> Bool {
        guard let messageData = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: messageData) as? [String: Any],
              let messageTopic = json["topic"] as? String,
              messageTopic == name else {
            return false
        }

        guard let messageId = json["id"] as? String, messageId == id else {
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
}


