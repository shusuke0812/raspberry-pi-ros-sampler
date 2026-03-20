//
//  FoxgloveUnsubscribe.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Unsubscribe メッセージ（クライアント → サーバー）
/// 購読の停止をリクエストする
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#unsubscribe
struct FoxgloveUnsubscribe: Codable {
    let op: FoxgloveMessageOperation
    let subscriptionIds: [UInt32]

    init(op: FoxgloveMessageOperation = .unsubscribe, subscriptionIds: [UInt32]) {
        self.op = op
        self.subscriptionIds = subscriptionIds
    }

    /// JSON 文字列にエンコードする
    func toJsonString() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
