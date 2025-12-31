//
//  RosServiceResponseHeader.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/16.
//

import Foundation

struct RosServiceResponseHeader: RosServiceResponseHeaderProtocol {
    let op: RosBridgeMessageOperation
    let id: String?
    let service: String
    let result: Bool
}
