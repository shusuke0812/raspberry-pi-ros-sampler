//
//  FoxgloveAdvertise.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Advertise メッセージ（サーバー → クライアント）
/// 利用可能なチャンネル（トピック）をクライアントに通知する
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise
struct FoxgloveAdvertise: Codable {
    let op: FoxgloveMessageOperation
    let channels: [FoxgloveAdvertiseChannel]

    init(op: FoxgloveMessageOperation = .advertise, channels: [FoxgloveAdvertiseChannel]) {
        self.op = op
        self.channels = channels
    }

    /// トピック名 → channelId のマッピングを返す
    func topicToChannelIdMap() -> [String: UInt32] {
        Dictionary(uniqueKeysWithValues: channels.map { ($0.topic, $0.id) })
    }
}

/// Advertise メッセージ内のチャンネル情報（サーバー → クライアント）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise
struct FoxgloveAdvertiseChannel: Codable {
    let id: UInt32
    let topic: String
    let encoding: String
    let schemaName: String
    let schema: String
    let schemaEncoding: String?
}
