//
//  WebSocketUrl.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/10/26.
//

import Foundation

struct WebSocketUrl {
    private let sheme = "ws"
    private let port: Int
    private let ipAddress: String

    init(ipAddress: String, port: Int = 9090) {
        self.ipAddress = ipAddress
        self.port = port
    }

    /// ROS Bridge 用の URL（ポート 9090）
    static func rosbridge(ipAddress: String) -> WebSocketUrl {
        WebSocketUrl(ipAddress: ipAddress, port: 9090)
    }

    /// Foxglove Bridge 用の URL（ポート 8765）
    static func foxglove(ipAddress: String) -> WebSocketUrl {
        WebSocketUrl(ipAddress: ipAddress, port: 8765)
    }

    var url: URL {
        let path = sheme + "://" + ipAddress + ":\(port)"
        return URL(string: path)! // TODO: pathに不正な文字列が入ったらクラッシュするのでバリデートする
    }
}
