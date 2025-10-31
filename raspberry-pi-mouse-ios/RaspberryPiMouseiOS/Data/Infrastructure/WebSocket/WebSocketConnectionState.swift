//
//  WebSocketConnectionState.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/27.
//

import Foundation

enum WebSocketConnectionState {
    case connecting
    case connected
    case disconnected(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    case connectingTimeout
}
