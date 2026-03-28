package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.RosBridgeMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * [Publish Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#333-publish--publish-)
 *
 * @param T メッセージ型（StringMessage, Int8Message, TwistMessage 等）
 */
@Serializable
data class RosTopicPublish<T>(
    val id: String? = null,
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.publish,
    val topic: String,
    @SerialName("msg")
    val message: T
)
