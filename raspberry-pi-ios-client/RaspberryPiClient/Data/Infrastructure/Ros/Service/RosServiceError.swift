//
//  RosServiceError.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/16.
//

import Foundation

enum RosServiceError: Error {
    case alreadyCalling
    case failedReceiveMessage(reason: Error)
    case failedDecodeMessage(reason: Error)
}
