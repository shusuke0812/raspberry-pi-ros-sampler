//
//  TurtlesimServiceResponse.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

struct TurtlesimServiceResponse: RosServiceResponseValuesProtocol, RosServiceResponseCdrDecodable {
    let name: String

    static func decodeFromCdr(_ data: Data) -> TurtlesimServiceResponse? {
        guard let name = CdrHelpers.decodeCdrString(from: data, at: 4) else { return nil }
        return TurtlesimServiceResponse(name: name)
    }
}
