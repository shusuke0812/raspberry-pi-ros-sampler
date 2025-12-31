//
//  RosCallService.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

struct RosCallService<A: RosCallServiceArgsProtocol, V: RosServiceResponseValuesProtocol>: RosCallServiceProtocol {
    typealias Response = RosServiceResponse<V>

    typealias Arg = A

    let header: any RosServiceHeaderProtocol
    let arg: A?
    let fragmentSize: Int?
    let compression: String?
    let timeout: TimeInterval?

    init(
        op: RosBridgeMessageOperation = .callService,
        id: String? = nil,
        service: String,
        arg: A? = nil,
        fragmentSize: Int? = nil,
        compression: String? = nil,
        timeout: TimeInterval? = nil
    ) {
        self.header = RosCallServiceHeader(
            op: op,
            id: id,
            service: service
        )
        self.arg = arg
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
        
        try container.encode(header.op, forKey: .op)
        try container.encodeIfPresent(header.id, forKey: .id)
        try container.encode(header.service, forKey: .service)
        if let arg = arg {
            try container.encode(arg, forKey: .args)
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

    func isEqual(to message: String) -> Bool {
        guard let jsonData = message.data(using: .utf8),
              let serviceHeader = try? JSONDecoder().decode(RosCallServiceHeader.self, from: jsonData)
        else {
            return false
        }

        if (serviceHeader.service != header.service) {
            return false
        }
        if let id = header.id, serviceHeader.id != id {
            return false
        }
        return true
    }
}
