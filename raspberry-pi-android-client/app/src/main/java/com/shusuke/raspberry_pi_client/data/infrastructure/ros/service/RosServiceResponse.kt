package com.shusuke.raspberry_pi_client.data.infrastructure.ros.service

import com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge.RosBridgeMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * [Service Response](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md)
 *
 * @param T レスポンス値型（EmptyService, TurtlesimServiceResponse 等）
 */
@Serializable
data class RosServiceResponse<T>(
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.serviceResponse,
    val id: String? = null,
    val service: String,
    val result: Boolean = true,
    @SerialName("values")
    val values: T? = null
)
