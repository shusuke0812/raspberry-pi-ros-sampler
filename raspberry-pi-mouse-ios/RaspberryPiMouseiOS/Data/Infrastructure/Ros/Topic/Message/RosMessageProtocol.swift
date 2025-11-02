//
//  RosMessageProtocol.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

protocol RosMessageProtocol: Codable {
    func toJsonString() -> String
}

extension RosMessageProtocol {
    func toJsonString() -> String {
        guard let jsonData = try? JSONEncoder().encode(self),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        return jsonString
    }
}
