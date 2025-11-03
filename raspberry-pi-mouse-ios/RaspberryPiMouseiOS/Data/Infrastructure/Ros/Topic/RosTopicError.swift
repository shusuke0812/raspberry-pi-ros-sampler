//
//  RosTopicError.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/3.
//

import Foundation

enum RosTopicError: Error {
    case failedConvertStringToData
    case failedDecodeMessageToRosPublish(reason: Error)

    var description: String {
        switch self {
        case .failedConvertStringToData:
            return "メッセージをデータ型に変換できませんでした"
        case .failedDecodeMessageToRosPublish(let reason):
            return "メッセージの変換に失敗しました\(reason)"
        }
    }
}
