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

/// サーバーがサポートするオプション機能
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#server-info
enum Capability: String, Codable, CaseIterable {
    /// クライアントがチャンネルを advertise してメッセージを送信できる
    case clientPublish
    /// クライアントがパラメータの取得・設定ができる
    case parameters
    /// クライアントがパラメータ変更を購読できる
    case parametersSubscribe
    /// サーバーがバイナリ Time メッセージを配信する
    case time
    /// クライアントがサービスを呼び出せる
    case services
    /// クライアントが接続グラフの更新を購読できる
    case connectionGraph
    /// クライアントがアセットを取得できる
    case assets
}

/// Foxglove でサポートされるエンコーディング
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#server-info
enum SupportedEncodings: String, Codable, CaseIterable {
    case json
    case protobuf
    case ros1
    case cdr
}
