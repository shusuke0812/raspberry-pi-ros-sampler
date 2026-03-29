package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge.RosBridgeMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * [Subscribe Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#334-subscribe)
 */
@Serializable
data class RosTopicSubscribe(
    val id: String? = null,
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.subscribe,
    val topic: String,
    @SerialName("type")
    val messageType: String,
    @SerialName("throttle_rate")
    val throttleRate: Int? = null
)
