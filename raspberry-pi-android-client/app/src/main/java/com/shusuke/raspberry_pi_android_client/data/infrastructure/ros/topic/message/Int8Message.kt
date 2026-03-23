package com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.message

import kotlinx.serialization.Serializable

/**
 * [std_msgs/msg/Int8](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/Int8.msg)
 */
@Serializable
data class Int8Message(
    val data: Byte = 0
)
