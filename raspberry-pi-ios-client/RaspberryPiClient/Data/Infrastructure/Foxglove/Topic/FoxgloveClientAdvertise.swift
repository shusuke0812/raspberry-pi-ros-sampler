//
//  FoxgloveClientAdvertise.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Client Advertise メッセージ（クライアント → サーバー）
/// クライアントが publish するチャンネルをサーバーに通知する
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#client-advertise
struct FoxgloveClientAdvertise: Codable {
    let op: FoxgloveMessageOperation
    let channels: [FoxgloveClientAdvertiseChannel]

    init(op: FoxgloveMessageOperation = .advertise, channels: [FoxgloveClientAdvertiseChannel]) {
        self.op = op
        self.channels = channels
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

/// Client Advertise メッセージ内のチャンネル情報（クライアント → サーバー）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#client-advertise
struct FoxgloveClientAdvertiseChannel: Codable {
    let id: UInt32
    let topic: String
    let encoding: String
    let schemaName: String
    let schema: String?
    let schemaEncoding: String?
}
