//
//  RosServiceResponseValue.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/16.
//

import Foundation

struct RosServiceResponseValue<T: RosServiceResponseValuesProtocol>: Codable {
    let values: [T]

    enum CodingKeys: String, CodingKey {
        case values
    }

    init(values: [T]) {
        self.values = values
    }
}
