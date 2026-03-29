package com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * [RosBridge Protocol](https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md)
 * の操作種別
 */
@Serializable
enum class RosBridgeMessageOperation {
    subscribe,
    publish,
    unsubscribe,
    @SerialName("call_service")
    callService,
    @SerialName("service_response")
    serviceResponse
}
