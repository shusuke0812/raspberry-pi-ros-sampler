//
//  RosTopicPublishHeader.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/9.
//

import Foundation

struct RosTopicPublishHeader: RosTopicPublishHeaderProtocol {
    let id: String?
    let op: RosBridgeMessageOperation
    let topic: String
}
