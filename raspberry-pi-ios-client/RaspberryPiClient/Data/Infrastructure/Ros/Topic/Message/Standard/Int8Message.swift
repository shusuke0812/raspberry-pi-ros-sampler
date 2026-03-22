//
//  Int8Message.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/9.
//

import Foundation

/// [std_msgs/msg/Int8](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/Int8.msg)
struct Int8Message: RosMessageProtocol, RosTopicMessageCdrDecodable {
    static var rosSchemaName: String { "std_msgs/msg/Int8" }

    let data: Int8

    enum CodingKeys: String, CodingKey {
        case data
    }

    /// CDR: encapsulation header (4 bytes) + int8 (1 byte)
    static func decodeFromCdr(data: Data) -> Int8Message? {
        guard data.count >= 5 else { return nil }
        return Int8Message(data: Int8(bitPattern: data[4]))
    }
}
