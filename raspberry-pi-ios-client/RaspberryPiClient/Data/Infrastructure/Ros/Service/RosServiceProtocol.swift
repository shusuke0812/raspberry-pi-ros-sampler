//
//  RosServiceProtocol.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

protocol RosServiceProtocol: Codable {
    var op: RosBridgeMessageOperation { get }
    var id: String? { get }
    var service: String { get }
}


// MARK: - Request

protocol RosCallServiceProtocol: RosServiceProtocol {
    associatedtype Response: Decodable
    associatedtype A: RosCallServiceArgsProtocol
    var args: [A] { get }
    var fragmentSize: Int? { get }
    var compression: String? { get }
    var timeout: Double? { get }
    func toJsonString() -> String?
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

protocol RosServiceResponseHeaderProtocol: RosServiceProtocol {
    var result: Bool { get }
}

protocol RosServiceResponseValuesProtocol: Codable {}


