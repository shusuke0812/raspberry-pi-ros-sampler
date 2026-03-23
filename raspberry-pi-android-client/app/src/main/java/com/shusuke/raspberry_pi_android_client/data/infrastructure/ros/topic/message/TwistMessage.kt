package com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.message

import kotlinx.serialization.Serializable

/**
 * [geometry_msgs/msg/Twist.msg](https://github.com/ros2/common_interfaces/blob/jazzy/geometry_msgs/msg/Twist.msg)
 */
@Serializable
data class TwistMessage(
    /** 並進速度 */
    val linear: Vector3Message = Vector3Message(),
    /** 角速度 */
    val angular: Vector3Message = Vector3Message()
)
