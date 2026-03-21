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
    private let protocols: [String]?

    init(ipAddress: String, port: Int, protocols: [String]? = nil) {
        self.ipAddress = ipAddress
        self.port = port
        self.protocols = protocols
    }

    /// ROS Bridge 用の URL（ポート 9090）
    static func rosbridge(ipAddress: String) -> WebSocketUrl {
        WebSocketUrl(ipAddress: ipAddress, port: 9090, protocols: nil)
    }

    /// Foxglove Bridge 用の URL（ポート 8765）
    /// [subprotocol ref](https://github.com/foxglove/foxglove-sdk/blob/main/ros/src/foxglove_bridge/include/foxglove_bridge/common.hpp#L12)
    static func foxglove(ipAddress: String) -> WebSocketUrl {
        WebSocketUrl(ipAddress: ipAddress, port: 8765, protocols: ["foxglove.sdk.v1"])
    }

    var url: URL {
        let path = sheme + "://" + ipAddress + ":\(port)"
        return URL(string: path)! // TODO: pathに不正な文字列が入ったらクラッシュするのでバリデートする
    }

    /// WebSocket接続用のURLRequest（protocolsプロパティをSec-WebSocket-Protocolヘッダーに設定）
    var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        if let protocols = protocols, !protocols.isEmpty {
            let protocolValue = protocols.joined(separator: ", ")
            request.setValue(protocolValue, forHTTPHeaderField: "Sec-WebSocket-Protocol")
        }
        return request
    }
}
