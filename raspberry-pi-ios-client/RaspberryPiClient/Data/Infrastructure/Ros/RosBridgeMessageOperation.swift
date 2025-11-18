//
//  RosBridgeMessageOperation.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

enum RosBridgeMessageOperation: String, Codable {
    case subscribe
    case publish
    case unsubscribe
    case callService = "call_service"
    case serviceResponse = "service_response"
}

/// RosBridgetClientのメッセージレスポンスの種別を判別するために使用する.
/// 判別した後、`publish`, `serviceResponse`毎にデコード処理を行う.
enum HandleRosBridgeMessageOperation {
    case publish
    case serviceResponse

    init?(_ op: RosBridgeMessageOperation) {
        switch op {
        case .publish:
            self = .publish
        case .serviceResponse:
            self = .serviceResponse
        default:
            return nil
        }
    }
}

struct HandleRosBridgeMessageResponse: Codable {
    var op: RosBridgeMessageOperation

    enum CodingKeys: String, CodingKey {
        case op
    }
}
