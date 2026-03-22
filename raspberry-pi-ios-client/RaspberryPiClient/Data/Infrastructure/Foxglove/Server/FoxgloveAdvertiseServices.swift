//
//  FoxgloveAdvertiseServices.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Advertise Services メッセージ（サーバー → クライアント）
/// 利用可能なサービスをクライアントに通知する
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise-services
struct FoxgloveAdvertiseServices: Codable {
    let op: FoxgloveMessageOperation
    let services: [FoxgloveAdvertiseService]

    init(op: FoxgloveMessageOperation = .advertiseServices, services: [FoxgloveAdvertiseService]) {
        self.op = op
        self.services = services
    }

    /// サービス名 → serviceId のマッピングを返す
    func serviceNameToIdMap() -> [String: UInt32] {
        Dictionary(uniqueKeysWithValues: services.map { ($0.name, $0.id) })
    }

    /// サービス名 → リクエスト encoding のマッピングを返す（advertiseServices の request.encoding）
    func serviceNameToRequestEncodingMap() -> [String: String] {
        Dictionary(uniqueKeysWithValues: services.compactMap { service in
            guard let encoding = service.request?.encoding else { return nil }
            return (service.name, encoding)
        })
    }
}

/// Advertise Services メッセージ内のサービス情報（サーバー → クライアント）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise-services
struct FoxgloveAdvertiseService: Codable {
    let id: UInt32
    let name: String
    let type: String?
    let request: FoxgloveServiceSchema?
    let response: FoxgloveServiceSchema?
    let requestSchema: String?
    let responseSchema: String?
}

/// サービスのリクエスト/レスポンススキーマ
struct FoxgloveServiceSchema: Codable {
    let encoding: String?
    let schemaName: String?
    let schemaEncoding: String?
    let schema: String?
}
