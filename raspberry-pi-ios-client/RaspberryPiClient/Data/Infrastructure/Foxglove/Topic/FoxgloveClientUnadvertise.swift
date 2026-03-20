//
//  FoxgloveClientUnadvertise.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Client Unadvertise メッセージ（クライアント → サーバー）
/// クライアントチャンネルの登録解除を通知する
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#client-unadvertise
struct FoxgloveClientUnadvertise: Codable {
    let op: FoxgloveMessageOperation
    let channelIds: [UInt32]

    init(op: FoxgloveMessageOperation = .unadvertise, channelIds: [UInt32]) {
        self.op = op
        self.channelIds = channelIds
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
