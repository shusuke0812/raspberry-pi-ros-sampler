//
//  FoxgloveServerInfo.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Server Info メッセージ（サーバー → クライアント）
/// 接続確立時にサーバーが必ず送信する
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#server-info
struct FoxgloveServerInfo: Codable {
    let op: FoxgloveMessageOperation
    let name: String
    let capabilities: [Capability]
    let supportedEncodings: [SupportedEncodings]?
    let metadata: [String: String]?
    let sessionId: String?

    init(
        op: FoxgloveMessageOperation = .serverInfo,
        name: String,
        capabilities: [Capability],
        supportedEncodings: [SupportedEncodings]? = nil,
        metadata: [String: String]? = nil,
        sessionId: String? = nil
    ) {
        self.op = op
        self.name = name
        self.capabilities = capabilities
        self.supportedEncodings = supportedEncodings
        self.metadata = metadata
        self.sessionId = sessionId
    }

    /// `clientPublish` がサポートされているか
    var supportsClientPublish: Bool {
        capabilities.contains(.clientPublish)
    }

    /// `services` がサポートされているか
    var supportsServices: Bool {
        capabilities.contains(.services)
    }

    /// JSON エンコーディングがサポートされているか
    var supportsJsonEncoding: Bool {
        supportedEncodings?.contains(.json) ?? false
    }
}

/// サーバーがサポートするオプション機能（Call Service / Topic Publish / Subscribe に必要なもののみ）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#server-info
enum Capability: String, Codable, CaseIterable {
    /// クライアントがチャンネルを advertise してメッセージを送信できる（Topic Publish）
    case clientPublish
    /// クライアントがサービスを呼び出せる（Call Service）
    case services

    /// 未サポートの capability（parameters, time, assets 等）
    case other = "__other__"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let known = Capability(rawValue: raw) {
            self = known
        } else {
            self = .other
        }
    }
}

/// Foxglove でサポートされるエンコーディング（Call Service / Topic Publish / Subscribe で使用するもののみ）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#server-info
enum SupportedEncodings: String, Codable, CaseIterable {
    case json
    case cdr

    /// 未サポートのエンコーディング（protobuf, ros1 等）
    case other = "__other__"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let known = SupportedEncodings(rawValue: raw) {
            self = known
        } else {
            self = .other
        }
    }
}
