package com.shusuke.raspberry_pi_client.data.infrastructure.ros.service

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.RosBridgeMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * [Call Service Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md)
 *
 * @param A サービス引数型（EmptyService, TurtlesimServiceArgs 等）
 */
@Serializable
data class RosCallService<A>(
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.callService,
    val id: String? = null,
    val service: String,
    @SerialName("args")
    val args: A? = null,
    val fragmentSize: Int? = null,
    val compression: String? = null,
    val timeout: Double? = null
)
