//
//  RosTopicSubscribe.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

/// [Subscribe Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#334-subscribe)
struct RosTopicSubscribe<T: RosMessageProtocol>: RosTopicSubscribeProtocol {
    let id: String?
    let op: RosBridgeMessageOperation
    let topic: String
    let messageType: String
    let throttelRate: Int?

    typealias Response = T

    enum CodingKeys: String, CodingKey {
        case id
        case op
        case topic
        case messageType = "type"
        case throttelRate = "throttle_rate"
    }

    init(id: String? = nil, topic: String, messageType: String, throttelRate: Int? = nil) {
        self.id = id
        self.op = RosBridgeMessageOperation.subscribe
        self.topic = topic
        self.messageType = messageType
        self.throttelRate = throttelRate
    }

    func isEqual(to message: String) -> Bool {
        guard let jsonData = message.data(using: .utf8),
              let topiHeader = try? JSONDecoder().decode(RosTopicPublishHeader.self, from: jsonData)
        else {
            return false
        }

        if (topiHeader.topic != topic) {
            return false
        }
        if let id = id, topiHeader.id != id {
            return false
        }
        return true
    }

    func decodeMessage(from jsonString: String) throws -> RosTopicPublish<Response> {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw RosTopicError.failedConvertStringToData
        }
        do {
            let result = try JSONDecoder().decode(RosTopicPublish<Response>.self, from: jsonData)
            return result
        } catch {
            throw RosTopicError.failedDecodeMessageToRosPublish(reason: error)
        }
    }
}
