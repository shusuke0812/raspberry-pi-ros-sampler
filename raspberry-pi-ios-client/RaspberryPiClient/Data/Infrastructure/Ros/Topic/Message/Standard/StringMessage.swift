//
//  StringMessage.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

/// [std_msgs/msg/String Message](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/String.msg)
struct StringMessage: RosMessageProtocol {
    static var rosSchemaName: String { "std_msgs/msg/String" }

    let data: String

    enum CodingKeys: String, CodingKey {
        case data
    }
}
