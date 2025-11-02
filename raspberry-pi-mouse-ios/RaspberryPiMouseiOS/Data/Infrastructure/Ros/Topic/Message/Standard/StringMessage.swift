//
//  StringMessage.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

/// [std_msgs/msg/String Message](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/String.msg)
struct StringMessage: RosMessageProtocol {
    let data: String

    enum CodingKeys: String, CodingKey {
        case data
    }
}
