//
//  FoxgloveSubscribe.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Subscribe メッセージ（クライアント → サーバー）
/// チャンネルへの購読をリクエストする
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#subscribe
struct FoxgloveSubscribe: Codable {
    let op: FoxgloveMessageOperation
    let subscriptions: [FoxgloveSubscribeSubscription]

    init(op: FoxgloveMessageOperation = .subscribe, subscriptions: [FoxgloveSubscribeSubscription]) {
        self.op = op
        self.subscriptions = subscriptions
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

/// Subscribe メッセージ内の購読情報（クライアント → サーバー）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#subscribe
struct FoxgloveSubscribeSubscription: Codable {
    let id: UInt32
    let channelId: UInt32
}
