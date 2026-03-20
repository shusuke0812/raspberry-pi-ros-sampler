//
//  TwistMessage.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/29.
//

import Foundation

/// [geometry_msgs/msg/Twist.msg](https://github.com/ros2/common_interfaces/blob/jazzy/geometry_msgs/msg/Twist.msg)
struct TwistMessage: RosMessageProtocol {
    static var rosSchemaName: String { "geometry_msgs/msg/Twist" }

    /// translational speed
    let linear: Vector3Message
    /// angular velocity
    let angular: Vector3Message
}
