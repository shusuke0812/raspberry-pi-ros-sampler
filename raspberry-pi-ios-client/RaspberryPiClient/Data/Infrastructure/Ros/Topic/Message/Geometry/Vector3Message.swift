//
//  Vector3Message.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/29.
//

import Foundation

/// [geometry_msgs/msg/Vector3.msg](https://github.com/ros2/common_interfaces/blob/jazzy/geometry_msgs/msg/Vector3.msg)
struct Vector3Message: RosMessageProtocol {
    static var rosSchemaName: String { "geometry_msgs/msg/Vector3" }

    let x: Double
    let y: Double
    let z: Double
}
