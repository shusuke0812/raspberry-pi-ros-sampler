//
//  RosServiceResponse.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

struct RosServiceResponse<T: RosServiceResponseValuesProtocol>: Decodable {
    let header: RosServiceResponseHeader
    let values: [T]

    init(id: String? = nil, service: String, values: [T], result: Bool) {
        self.header = RosServiceResponseHeader(
            op: RosBridgeMessageOperation.serviceResponse,
            id: id,
            service: service,
            result: result
        )
        self.values = values
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // header
        let op = try container.decode(RosBridgeMessageOperation.self, forKey: .op)
        let id = try container.decodeIfPresent(String.self, forKey: .id)
        let service = try container.decode(String.self, forKey: .service)
        let result = try container.decode(Bool.self, forKey: .result)
        self.header = .init(op: op, id: id, service: service, result: result)

        // values
        self.values = try container.decode([T].self, forKey: .values)
    }

    enum CodingKeys: String, CodingKey {
        case op
        case id
        case service
        case values
        case result
    }
}
