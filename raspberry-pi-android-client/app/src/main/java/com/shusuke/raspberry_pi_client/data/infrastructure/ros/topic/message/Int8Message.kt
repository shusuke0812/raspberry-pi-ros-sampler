package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message

import kotlinx.serialization.Serializable

/**
 * [std_msgs/msg/Int8](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/Int8.msg)
 */
@Serializable
data class Int8Message(
    val data: Byte = 0
) {
    companion object {
        /** ROS2 の `type` / schema 名（[RosTopicSubscribe.messageType] 等と一致させる） */
        const val ROS_MESSAGE_TYPE = "std_msgs/msg/Int8"

        /** CDR: カプセル 4 バイト + int8 1 バイト */
        fun decodeFromCdr(data: ByteArray): Int8Message? {
            if (data.size < 5) return null
            return Int8Message(data = data[4])
        }
    }
}
