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
