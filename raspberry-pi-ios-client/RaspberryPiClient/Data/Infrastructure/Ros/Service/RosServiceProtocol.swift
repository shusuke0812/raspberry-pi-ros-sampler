//
//  RosServiceProtocol.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

protocol RosServiceHeaderProtocol: Codable {
    var op: RosBridgeMessageOperation { get }
    var id: String? { get }
    var service: String { get }
}


// MARK: - Request

protocol RosCallServiceProtocol: Encodable {
    associatedtype Response: RosServiceResponseProtocol
    associatedtype Arg: RosCallServiceArgsProtocol
    var header: any RosServiceHeaderProtocol { get }
    var arg: Arg? { get }
    var fragmentSize: Int? { get }
    var compression: String? { get }
    var timeout: Double? { get }
    func toJsonString() -> String?
    func isEqual(to message: String) -> Bool
}

protocol RosCallServiceArgsProtocol: Codable {}

/// CDR 形式でエンコード可能なサービス引数（Foxglove Bridge の encoding: "cdr" 用）
protocol RosCallServiceCdrEncodable {
    func encodeCdr() -> Data
}

extension RosCallServiceProtocol {
    func toJsonString() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

// MARK: - Response

protocol RosServiceResponseHeaderProtocol: RosServiceHeaderProtocol {
    var result: Bool { get }
}

protocol RosServiceResponseValuesProtocol: Codable {}

protocol RosServiceResponseProtocol: Decodable {}

/// CDR 形式からデコード可能なサービスレスポンス（Foxglove Bridge の encoding: "cdr" 用）
protocol RosServiceResponseCdrDecodable {
    static func decodeFromCdr(_ data: Data) -> Self?
}

/// RosServiceResponse を CDR からデコード可能にするプロトコル
protocol RosServiceResponseCdrDecodableProtocol {
    static func decodeFromCdr(data: Data, serviceName: String) -> Self?
}
