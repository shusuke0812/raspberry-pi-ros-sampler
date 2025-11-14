//
//  HelloTopicResponse.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/11/3.
//

import Foundation

typealias HelloTopicResponse = RosTopicPublish<StringMessage>
typealias HelloSignalTopicResponse = RosTopicPublish<Int8Message>
