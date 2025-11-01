//
//  WebSocketConnectionState.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/27.
//

import Foundation

enum WebSocketConnectionState: Equatable {
    case ready
    case connecting
    case connected
    case disconnected(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    case connectingTimeout

    var description: String {
        switch self {
        case .ready:
            return "未接続"
        case .connecting:
            return "接続中..."
        case .connected:
            return "接続"
        case .disconnected(let closeCode, let reason):
            if let reasonData = reason, let reasonString = String(data: reasonData, encoding: .utf8) {
                return "切断(code: \(closeCode.rawValue))\n\(reasonString)"
            }
            return "切断(code: \(closeCode.rawValue))"
        case .connectingTimeout:
            return "接続タイムアウトエラー"
        }
    }
}
