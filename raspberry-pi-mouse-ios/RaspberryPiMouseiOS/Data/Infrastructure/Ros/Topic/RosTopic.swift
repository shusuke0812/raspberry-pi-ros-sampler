//
//  RosTopic.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

struct RosTopic {
    let id: String = UUID().uuidString
    let op: Operation
    let name: String
    let messageType: String
    let throttelRate: Int?

    enum Operation: String {
        case subscribe
        case publish
        case unsubscribe
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
        guard let jsonData = try? JSONSerialization.data(withJSONObject: toDictionary()),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }

    private func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            "op": op.rawValue,
            "id": id,
            "topic": name,
            "type": messageType
        ]

        if let throttelRate = throttelRate {
            dictionary["throttle_rate"] = throttelRate
        }

        return dictionary
    }
}


