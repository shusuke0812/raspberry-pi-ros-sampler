//
//  RosServiceError.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/16.
//

import Foundation

enum RosServiceError: Error {
    case alreadyCalling // TODO: 不要？
    case failedReceiveMessage(reason: Error)
    case failedDecodeMessage(reason: Error)

    var description: String {
        switch self {
        case .alreadyCalling:
            return ""
        case .failedReceiveMessage(let reason):
            return "サービスの送信に失敗しました\n\(reason.localizedDescription)"
        case .failedDecodeMessage(let reason):
            return "レスポンスの変換に失敗しました\(reason.localizedDescription)"
        }
    }
}
