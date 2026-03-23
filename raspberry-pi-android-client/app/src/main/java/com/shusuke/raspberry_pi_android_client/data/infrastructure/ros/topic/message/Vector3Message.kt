package com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.message

import kotlinx.serialization.Serializable

/**
 * [geometry_msgs/msg/Vector3.msg](https://github.com/ros2/common_interfaces/blob/jazzy/geometry_msgs/msg/Vector3.msg)
 */
@Serializable
data class Vector3Message(
    val x: Double = 0.0,
    val y: Double = 0.0,
    val z: Double = 0.0
)
