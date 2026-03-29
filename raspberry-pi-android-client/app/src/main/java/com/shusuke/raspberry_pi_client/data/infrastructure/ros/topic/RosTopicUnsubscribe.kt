package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge.RosBridgeMessageOperation
import kotlinx.serialization.Serializable

/**
 * [Unsubscribe Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#335-unsubscribe)
 */
@Serializable
data class RosTopicUnsubscribe(
    val id: String? = null,
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.unsubscribe,
    val topic: String
)
