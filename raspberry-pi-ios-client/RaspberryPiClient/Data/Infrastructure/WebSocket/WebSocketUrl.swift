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

    var url: URL {
        let path = sheme + "://" + ipAddress + ":\(port)"
        return URL(string: path)!
    }
}
