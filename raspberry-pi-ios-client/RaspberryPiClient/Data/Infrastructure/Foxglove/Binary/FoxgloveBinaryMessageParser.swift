//
//  FoxgloveBinaryMessageParser.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Foxglove バイナリメッセージのパーサ（サーバー → クライアント）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#binary-messages
struct FoxgloveBinaryMessageParser {
    /// サーバーから受信したバイナリデータをパースする
    /// - Parameter data: 受信したバイナリデータ（1バイト目が opcode）
    /// - Returns: パース結果
    static func parseServerMessage(_ data: Data) -> FoxgloveServerBinaryMessage {
        guard !data.isEmpty else {
            return .unknown(opcode: 0, error: .insufficientData)
        }

        let opcode = data[0]
        let payload = data.dropFirst(1)

        switch opcode {
        case FoxgloveServerBinaryOpcode.messageData.rawValue:
            return parseMessageData(payload)
        case FoxgloveServerBinaryOpcode.time.rawValue:
            return parseTime(payload)
        case FoxgloveServerBinaryOpcode.serviceCallResponse.rawValue:
            return parseServiceCallResponse(payload)
        case FoxgloveServerBinaryOpcode.fetchAssetResponse.rawValue:
            return parseFetchAssetResponse(payload)
        default:
            return .unknown(opcode: opcode, error: nil)
        }
    }

    // MARK: - Message Data (0x01)
    // | 4 bytes: subscription id (uint32) |
    // | 8 bytes: timestamp (uint64) |
    // | remaining: payload |
    private static func parseMessageData(_ data: Data) -> FoxgloveServerBinaryMessage {
        guard data.count >= 12 else {
            return .unknown(opcode: 0x01, error: .insufficientData)
        }
        let subscriptionId = data.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
        let timestamp = data.dropFirst(4).withUnsafeBytes { $0.load(as: UInt64.self).littleEndian }
        let payload = data.dropFirst(12)
        return .messageData(subscriptionId: subscriptionId, timestamp: timestamp, payload: Data(payload))
    }

    // MARK: - Time (0x02)
    // | 8 bytes: timestamp (uint64) |
    private static func parseTime(_ data: Data) -> FoxgloveServerBinaryMessage {
        guard data.count >= 8 else {
            return .unknown(opcode: 0x02, error: .insufficientData)
        }
        let timestamp = data.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian }
        return .time(timestamp: timestamp)
    }

    // MARK: - Service Call Response (0x03)
    // | 4 bytes: service id (uint32) |
    // | 4 bytes: call id (uint32) |
    // | 4 bytes: encoding length (uint32) |
    // | encoding length bytes: encoding (char[]) |
    // | remaining: payload |
    private static func parseServiceCallResponse(_ data: Data) -> FoxgloveServerBinaryMessage {
        guard data.count >= 12 else {
            return .unknown(opcode: 0x03, error: .insufficientData)
        }
        let serviceId = data.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
        let callId = data.dropFirst(4).withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
        let encodingLength = Int(data.dropFirst(8).withUnsafeBytes { $0.load(as: UInt32.self).littleEndian })
        guard data.count >= 12 + encodingLength else {
            return .unknown(opcode: 0x03, error: .insufficientData)
        }
        let encodingData = data.dropFirst(12).prefix(encodingLength)
        guard let encoding = String(data: Data(encodingData), encoding: .utf8) else {
            return .unknown(opcode: 0x03, error: .invalidEncoding)
        }
        let payload = data.dropFirst(12 + encodingLength)
        return .serviceCallResponse(serviceId: serviceId, callId: callId, encoding: encoding, payload: Data(payload))
    }

    // MARK: - Fetch Asset Response (0x04)
    // | 4 bytes: request id (uint32) |
    // | 1 byte: status (uint8) |
    // | 4 bytes: error message length (uint32) |
    // | error message length bytes: error message |
    // | remaining: asset data |
    private static func parseFetchAssetResponse(_ data: Data) -> FoxgloveServerBinaryMessage {
        guard data.count >= 9 else {
            return .unknown(opcode: 0x04, error: .insufficientData)
        }
        let requestId = data.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
        let status = data[4]
        let errorMessageLength = Int(data.dropFirst(5).withUnsafeBytes { $0.load(as: UInt32.self).littleEndian })
        guard data.count >= 9 + errorMessageLength else {
            return .unknown(opcode: 0x04, error: .insufficientData)
        }
        let errorMessageData = data.dropFirst(9).prefix(errorMessageLength)
        let errorMessage = String(data: Data(errorMessageData), encoding: .utf8) ?? ""
        let assetData = data.dropFirst(9 + errorMessageLength)
        return .fetchAssetResponse(requestId: requestId, status: status, errorMessage: errorMessage, assetData: Data(assetData))
    }
}

/// サーバー → クライアントのバイナリメッセージ opcode（本ファイル内でのみ使用）
private enum FoxgloveServerBinaryOpcode: UInt8 {
    case messageData = 0x01
    case time = 0x02
    case serviceCallResponse = 0x03
    case fetchAssetResponse = 0x04
}

/// サーバーから受信したバイナリメッセージのパース結果
enum FoxgloveServerBinaryMessage {
    /// Message Data（opcode 0x01）
    /// subscription id, timestamp, payload
    case messageData(subscriptionId: UInt32, timestamp: UInt64, payload: Data)

    /// Time（opcode 0x02）
    case time(timestamp: UInt64)

    /// Service Call Response（opcode 0x03）
    /// service id, call id, encoding, payload
    case serviceCallResponse(serviceId: UInt32, callId: UInt32, encoding: String, payload: Data)

    /// Fetch Asset Response（opcode 0x04）
    case fetchAssetResponse(requestId: UInt32, status: UInt8, errorMessage: String, assetData: Data)

    /// 不明な opcode またはパースエラー
    case unknown(opcode: UInt8, error: FoxgloveBinaryParseError?)
}

enum FoxgloveBinaryParseError: Error {
    case insufficientData
    case invalidEncoding
}
