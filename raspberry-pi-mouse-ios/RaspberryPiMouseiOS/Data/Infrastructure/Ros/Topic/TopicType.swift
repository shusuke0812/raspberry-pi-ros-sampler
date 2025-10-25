//
//  TopicType.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/25.
//

import Foundation

protocol TopicType {
    var name: String { get set }
    var messageType: String { get set }
    var throttleRate: Int? { get set }
}
