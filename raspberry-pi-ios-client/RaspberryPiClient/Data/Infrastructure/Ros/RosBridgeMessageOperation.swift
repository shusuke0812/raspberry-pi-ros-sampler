//
//  RosBridgeMessageOperation.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

enum RosBridgeMessageOperation: String, Codable {
    case subscribe
    case publish
    case unsubscribe
}
