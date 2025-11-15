//
//  RosServiceResponse.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

struct RosServiceResponse<T: RosServiceResponseValuesProtocol>: RosServiceResponseProtocol {
    typealias V = T

    let op: RosBridgeMessageOperation
    let id: String?
    let service: String
    let values: [T]
    let result: Bool

    init(
        op: RosBridgeMessageOperation = .serviceResponse,
        id: String? = nil,
        service: String,
        values: [T],
        result: Bool
    ) {
        self.op = op
        self.id = id
        self.service = service
        self.values = values
        self.result = result
    }
}
