//
//  StringMessage.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

/// [std_msgs/msg/String Message](https://docs.ros2.org/foxy/api/std_msgs/msg/String.html)
struct StringMessage: RosMessage {
    let data: String

    enum CodingKeys: String, CodingKey {
        case data
    }
}
