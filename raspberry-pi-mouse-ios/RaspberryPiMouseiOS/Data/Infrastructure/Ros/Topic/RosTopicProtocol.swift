//
//  RosTopicProtocol.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/11/1.
//

import Foundation

protocol RosTopicProtocol {
    var op: RosTopicOperation { get }
    var id: String? { get }
    var topic: String { get }
}
