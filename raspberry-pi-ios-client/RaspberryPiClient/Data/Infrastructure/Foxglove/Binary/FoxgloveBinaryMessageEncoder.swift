//
//  FoxgloveBinaryMessageEncoder.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// クライアント → サーバーへのバイナリメッセージエンコーダ
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#binary-messages
struct FoxgloveBinaryMessageEncoder {
    /// Client Message Data（opcode 0x01）をエンコードする
    /// - Parameters:
    ///   - channelId: Client Advertise で登録したチャンネル ID
    ///   - payload: メッセージペイロード（JSON エンコード済みなど）
    /// - Returns: 送信用バイナリデータ
    static func encodeClientMessageData(channelId: UInt32, payload: Data) -> Data {
        var data = Data()
        data.append(FoxgloveClientBinaryOpcode.clientMessageData.rawValue)
        data.append(contentsOf: withUnsafeBytes(of: channelId.littleEndian) { Array($0) })
        data.append(payload)
        return data
    }

    /// Service Call Request（opcode 0x02）をエンコードする
    /// - Parameters:
    ///   - serviceId: Advertise Services で取得したサービス ID
    ///   - callId: レスポンスと対応付けるための一意な ID
    ///   - encoding: エンコーディング名（例: "json"）
    ///   - payload: リクエストペイロード
    /// - Returns: 送信用バイナリデータ
    static func encodeServiceCallRequest(serviceId: UInt32, callId: UInt32, encoding: String, payload: Data) -> Data {
        guard let encodingData = encoding.data(using: .utf8) else {
            return Data()
        }
        let encodingLength = UInt32(encodingData.count)

        var data = Data()
        data.append(FoxgloveClientBinaryOpcode.serviceCallRequest.rawValue)
        data.append(contentsOf: withUnsafeBytes(of: serviceId.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: callId.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: encodingLength.littleEndian) { Array($0) })
        data.append(encodingData)
        data.append(payload)
        return data
    }
}

/// クライアント → サーバーのバイナリメッセージ opcode（本ファイル内でのみ使用）
private enum FoxgloveClientBinaryOpcode: UInt8 {
    case clientMessageData = 0x01
    case serviceCallRequest = 0x02
}
