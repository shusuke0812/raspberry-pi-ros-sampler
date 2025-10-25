//
//  TopicManager.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

class TopicManager {
    private let rosBridgeClient: RosBridgeClient
    private let topicType: TopicType

    init(rosBridgeClient: RosBridgeClient, topicType: TopicType) {
        self.rosBridgeClient = rosBridgeClient
        self.topicType = topicType
    }

    func subscribe() {
    }
}
