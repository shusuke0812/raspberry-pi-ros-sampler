//
//  EmptyServiceValue.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/15.
//

import Foundation

/// values が nil の場合に使用する空の型
struct EmptyServiceValue: RosCallServiceArgsProtocol {
    init() {}
}
