//
//  ConnectionMode.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/21.
//

import Foundation

/// 接続先の Bridge 種別
enum ConnectionMode: String, CaseIterable {
    case rosBridge = "ROS Bridge"
    case foxgloveBridge = "Foxglove Bridge"

    var port: Int {
        switch self {
        case .rosBridge: return 9090
        case .foxgloveBridge: return 8765
        }
    }
}
