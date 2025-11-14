//
//  RosServiceProtocol.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

protocol RosCallServiceProtocol: RosServiceProtocol {
    var args: [[String: Any]]? { get }
    var fragmentSize: Int? { get }
    var compression: String? { get }
    var timeout: Double? { get }
}

protocol RosServiceResponseProtocol: RosServiceProtocol {
    var values: [[String: Any]]? { get }
    var result: Bool { get }
}

protocol RosServiceProtocol: Codable {
    var op: RosBridgeMessageOperation { get }
    var id: String? { get }
    var service: String { get }
}
