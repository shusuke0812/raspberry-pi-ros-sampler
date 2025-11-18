//
//  RosCallService.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

struct RosCallService<A: RosCallServiceArgsProtocol, V: RosServiceResponseValuesProtocol>: RosCallServiceProtocol {
    typealias Response = RosServiceResponse<V>

    typealias A = A

    let op: RosBridgeMessageOperation
    let id: String?
    let service: String
    let args: [A]
    let fragmentSize: Int?
    let compression: String?
    let timeout: TimeInterval?

    init(
        op: RosBridgeMessageOperation = .callService,
        id: String? = nil,
        service: String,
        args: [A] = [],
        fragmentSize: Int? = nil,
        compression: String? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.op = op
        self.id = id
        self.service = service
        self.args = args
        self.fragmentSize = fragmentSize
        self.compression = compression
        self.timeout = timeout
    }

    enum CodingKeys: String, CodingKey {
        case op
        case id
        case service
        case args
        case fragmentSize
        case compression
        case timeout
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(op, forKey: .op)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(service, forKey: .service)
        if !args.isEmpty {
            try container.encode(args, forKey: .args)
        }
        if let fragmentSize = fragmentSize {
            try container.encode(fragmentSize, forKey: .fragmentSize)
        }
        if let compression = compression {
            try container.encode(compression, forKey: .compression)
        }
        if let timeout = timeout {
            try container.encode(timeout, forKey: .timeout)
        }
    }
}
