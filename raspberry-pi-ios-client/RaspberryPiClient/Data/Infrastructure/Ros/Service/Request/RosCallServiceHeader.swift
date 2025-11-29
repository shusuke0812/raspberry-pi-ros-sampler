//
//  RosCallServiceHeader.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/29.
//

struct RosCallServiceHeader: RosServiceProtocol {
    let op: RosBridgeMessageOperation
    let id: String?
    let service: String
}
