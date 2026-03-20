//
//  RosMessageProtocol.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

protocol RosMessageProtocol: Codable {
    func toJsonString() -> String
    /// Foxglove Bridge の Client Advertise で使用する ROS メッセージ型名（例: geometry_msgs/msg/Twist）
    static var rosSchemaName: String { get }
}

extension RosMessageProtocol {
    static var rosSchemaName: String { "unknown" }

    func toJsonString() -> String {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        return jsonString
    }
}
