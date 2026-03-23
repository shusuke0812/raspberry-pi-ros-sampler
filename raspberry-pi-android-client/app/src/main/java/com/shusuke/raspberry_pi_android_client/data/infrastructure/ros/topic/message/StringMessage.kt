package com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.message

import kotlinx.serialization.Serializable

/**
 * [std_msgs/msg/String Message](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/String.msg)
 */
@Serializable
data class StringMessage(
    val data: String = ""
)
