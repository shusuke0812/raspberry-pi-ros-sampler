//
//  RosTopicSubscribeTests.swift
//  RaspberryPiMouseiOSTests
//
//  Created by Shusuke Ota on 2025/11/2.
//

import Testing
@testable import RaspberryPiMouseiOS

struct RosTopicSubscribeTests {
    private let topicSubscribeMock = RosTopicSubscribe<StringMessage>(topic: "/hello", messageType: "std_msgs/String")
    private let topicSubscribeResponseMock = """
    {
        "op": "publish", 
        "topic": "/hello", 
        "msg": {"data": "Hello world"}
    }
    """

    // MARK: - Success

    @Test func testDecodeMessageToRosTopicPublish() {
        let message = topicSubscribeMock.decodeMessage(from: topicSubscribeResponseMock)
        #expect(message != nil)
    }

    @Test func testMatchingMessage() {
        let isEuqal = topicSubscribeMock.isEqual(to: topicSubscribeResponseMock)
        #expect(isEuqal == true)
    }
}
