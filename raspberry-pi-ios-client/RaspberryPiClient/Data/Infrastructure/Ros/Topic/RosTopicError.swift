//
//  RosTopicError.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/3.
//

import Foundation

enum RosTopicError: Error {
    case alreadySubscribed
    case failedReceiveMessage(reason: Error)
    case failedConvertStringToData
    case failedDecodeMessageToRosPublish(reason: Error)

    var description: String {
        switch self {
        case .alreadySubscribed:
            return "すでに購読済みのトピックです"
        case .failedReceiveMessage(let reason):
            return "メッセージの受信に失敗しました\(reason.localizedDescription)"
        case .failedConvertStringToData:
            return "メッセージをデータ型に変換できませんでした"
        case .failedDecodeMessageToRosPublish(let reason):
            return "メッセージの変換に失敗しました\(reason.localizedDescription)"
        }
    }
}
