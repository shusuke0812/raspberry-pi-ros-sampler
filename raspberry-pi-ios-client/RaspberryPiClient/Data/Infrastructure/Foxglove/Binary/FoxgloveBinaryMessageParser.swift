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
            return parseMessageData(Data(payload))
        case FoxgloveServerBinaryOpcode.serviceCallResponse.rawValue:
            return parseServiceCallResponse(Data(payload))
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
        let subscriptionId = data.loadUInt32LittleEndian(at: 0)
        let timestamp = data.loadUInt64LittleEndian(at: 4)
        let payload = data.dropFirst(12)
        return .messageData(subscriptionId: subscriptionId, timestamp: timestamp, payload: Data(payload))
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
        let serviceId = data.loadUInt32LittleEndian(at: 0)
        let callId = data.loadUInt32LittleEndian(at: 4)
        let encodingLength = Int(data.loadUInt32LittleEndian(at: 8))
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
}

/// サーバー → クライアントのバイナリメッセージ opcode（本ファイル内でのみ使用）
private enum FoxgloveServerBinaryOpcode: UInt8 {
    case messageData = 0x01
    case serviceCallResponse = 0x03
}

/// サーバーから受信したバイナリメッセージのパース結果
enum FoxgloveServerBinaryMessage {
    /// Message Data（opcode 0x01）
    /// subscription id, timestamp, payload
    case messageData(subscriptionId: UInt32, timestamp: UInt64, payload: Data)

    /// Service Call Response（opcode 0x03）
    /// service id, call id, encoding, payload
    case serviceCallResponse(serviceId: UInt32, callId: UInt32, encoding: String, payload: Data)

    /// 不明な opcode またはパースエラー
    case unknown(opcode: UInt8, error: FoxgloveBinaryParseError?)
}

enum FoxgloveBinaryParseError: Error {
    case insufficientData
    case invalidEncoding
}


private extension DataProtocol {
    /// アライメントに依存せず little-endian の UInt32 を読み取る（Data/Data.SubSequence 両対応、Index ベースで安全にアクセス）
    func loadUInt32LittleEndian(at offset: Int) -> UInt32 {
        let i0 = index(startIndex, offsetBy: offset)
        let i1 = index(startIndex, offsetBy: offset + 1)
        let i2 = index(startIndex, offsetBy: offset + 2)
        let i3 = index(startIndex, offsetBy: offset + 3)
        return UInt32(self[i0]) | (UInt32(self[i1]) << 8) | (UInt32(self[i2]) << 16) | (UInt32(self[i3]) << 24)
    }

    /// アライメントに依存せず little-endian の UInt64 を読み取る
    func loadUInt64LittleEndian(at offset: Int) -> UInt64 {
        UInt64(loadUInt32LittleEndian(at: offset)) | (UInt64(loadUInt32LittleEndian(at: offset + 4)) << 32)
    }
}
