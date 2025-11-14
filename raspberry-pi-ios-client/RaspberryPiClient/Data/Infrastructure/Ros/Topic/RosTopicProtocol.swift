//
//  RosTopicProtocol.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

protocol RosTopicUnsubscribeProtocol: RosTopicProtocol {}

protocol RosTopicSubscribeProtocol: RosTopicProtocol {
    associatedtype Response: RosMessageProtocol
}

protocol RosTopicPublishHeaderProtocol: RosTopicProtocol {}

protocol RosTopicProtocol: Codable {
    var op: RosTopicOperation { get }
    var id: String? { get }
    var topic: String { get }
    func toJsonString() -> String?
}

extension RosTopicProtocol {
    func toJsonString() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
