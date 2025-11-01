//
//  RosTopicOperation.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

enum RosTopicOperation: String, Codable {
    case subscribe
    case publish
    case unsubscribe
}
