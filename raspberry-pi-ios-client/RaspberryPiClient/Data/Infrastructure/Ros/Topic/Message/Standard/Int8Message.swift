//
//  Int8Message.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/9.
//

import Foundation

/// [std_msgs/msg/Int8](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/Int8.msg)
struct Int8Message: RosMessageProtocol {
    static var rosSchemaName: String { "std_msgs/msg/Int8" }

    let data: Int8

    enum CodingKeys: String, CodingKey {
        case data
    }
}
