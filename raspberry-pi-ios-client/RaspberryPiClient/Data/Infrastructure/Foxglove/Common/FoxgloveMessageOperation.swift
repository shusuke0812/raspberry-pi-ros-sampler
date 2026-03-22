//
//  FoxgloveMessageOperation.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Foxglove WebSocket プロトコルの JSON メッセージ種別（JSONの"op"フィールド）
/// Call Service / Topic Publish / Subscribe に必要な op のみサポート。それ以外は .other として受信
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md
enum FoxgloveMessageOperation: String, Codable {
    // Server → Client
    case serverInfo = "serverInfo"
    case advertise
    case unadvertise
    case advertiseServices = "advertiseServices"
    case unadvertiseServices = "unadvertiseServices"
    case serviceCallFailure = "serviceCallFailure"

    // Client → Server
    case subscribe
    case unsubscribe

    /// 未サポートの op（parameterValues, fetchAsset 等）
    case other = "__other__"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let known = FoxgloveMessageOperation(rawValue: raw) {
            self = known
        } else {
            self = .other
        }
    }
}
