//
//  WebSocketUrl.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/26.
//

import Foundation

struct WebSocketUrl {
    private let sheme = "ws://"
    private let port = 9090
    private let ipString: String

    init(ipString: String) {
        self.ipString = ipString
    }

    var url: URL {
        let path = sheme + ipString + ":\(port)"
        return URL(string: path)!
    }
}
