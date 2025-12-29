//
//  TurtlesimServiceArgs.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

struct TurtlesimServiceArgs: RosCallServiceArgsProtocol {
    let x: Float
    let y: Float
    let theta: Float
    let name: String?
}
