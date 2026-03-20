//
//  FoxgloveJsonMessageParser.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Foxglove JSON メッセージのパーサ（サーバー → クライアント）
struct FoxgloveJsonMessageParser {
    /// JSON 文字列をパースしてメッセージ種別に応じた結果を返す
    /// - Parameter jsonString: 受信した JSON 文字列
    /// - Returns: パース結果。パースに失敗した場合は nil
    static func parseServerMessage(_ jsonString: String) -> FoxgloveServerJsonMessage? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return parseServerMessage(jsonData)
    }

    /// JSON データをパースしてメッセージ種別に応じた結果を返す
    /// - Parameter jsonData: 受信した JSON データ
    /// - Returns: パース結果。パースに失敗した場合は nil
    private static func parseServerMessage(_ jsonData: Data) -> FoxgloveServerJsonMessage? {
        guard let header = try? JSONDecoder().decode(FoxgloveMessageHeader.self, from: jsonData) else {
            return nil
        }

        let decoder = JSONDecoder()
        switch header.op {
        case .serverInfo:
            guard let info = try? decoder.decode(FoxgloveServerInfo.self, from: jsonData) else { return nil }
            return .serverInfo(info)
        case .advertise:
            guard let advertise = try? decoder.decode(FoxgloveAdvertise.self, from: jsonData) else { return nil }
            return .advertise(advertise)
        case .unadvertise:
            guard let body = try? decoder.decode(FoxgloveUnadvertiseBody.self, from: jsonData) else { return nil }
            return .unadvertise(channelIds: body.channelIds)
        case .advertiseServices:
            guard let services = try? decoder.decode(FoxgloveAdvertiseServices.self, from: jsonData) else { return nil }
            return .advertiseServices(services)
        case .unadvertiseServices:
            guard let body = try? decoder.decode(FoxgloveUnadvertiseServicesBody.self, from: jsonData) else { return nil }
            return .unadvertiseServices(serviceIds: body.serviceIds)
        case .status:
            guard let body = try? decoder.decode(FoxgloveStatusBody.self, from: jsonData) else { return nil }
            return .status(level: body.level, message: body.message, id: body.id)
        case .serviceCallFailure:
            guard let body = try? decoder.decode(FoxgloveServiceCallFailureBody.self, from: jsonData) else { return nil }
            return .serviceCallFailure(serviceId: body.serviceId, callId: body.callId, message: body.message)
        default:
            return .other(op: header.op)
        }
    }
}

/// サーバーから受信した JSON メッセージのパース結果
enum FoxgloveServerJsonMessage {
    case serverInfo(FoxgloveServerInfo)
    case advertise(FoxgloveAdvertise)
    case unadvertise(channelIds: [UInt32])
    case advertiseServices(FoxgloveAdvertiseServices)
    case unadvertiseServices(serviceIds: [UInt32])
    case status(level: Int, message: String, id: String?)
    case serviceCallFailure(serviceId: UInt32, callId: UInt32, message: String)
    case other(op: FoxgloveMessageOperation)
}

// MARK: - Private body types for partial parsing

private struct FoxgloveUnadvertiseBody: Codable {
    let channelIds: [UInt32]
}

private struct FoxgloveUnadvertiseServicesBody: Codable {
    let serviceIds: [UInt32]
}

private struct FoxgloveStatusBody: Codable {
    let level: Int
    let message: String
    let id: String?
}

private struct FoxgloveServiceCallFailureBody: Codable {
    let serviceId: UInt32
    let callId: UInt32
    let message: String
}

// MARK: - Private

/// JSON メッセージの op フィールドのみをパースして種別を判別するための基底型
private struct FoxgloveMessageHeader: Codable {
    let op: FoxgloveMessageOperation
}
