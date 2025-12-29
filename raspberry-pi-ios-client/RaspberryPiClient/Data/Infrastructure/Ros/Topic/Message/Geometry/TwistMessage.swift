//
//  TwistMessage.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/29.
//

import Foundation

struct TwistMessage: RosMessageProtocol {
    /// translational speed
    let linear: Vector3Message
    /// angular velocity
    let angular: Vector3Message
}
