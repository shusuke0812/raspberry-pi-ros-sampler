package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.cdr.CdrHelpers
import kotlinx.serialization.Serializable

/**
 * [std_msgs/msg/String Message](https://github.com/ros2/common_interfaces/blob/jazzy/std_msgs/msg/String.msg)
 */
@Serializable
data class StringMessage(
    val data: String = ""
) {
    companion object {
        /** ROS2 の `type` / schema 名（[RosTopicSubscribe.messageType] 等と一致させる） */
        const val ROS_MESSAGE_TYPE = "std_msgs/msg/String"

        /** CDR: カプセル 4 バイトの直後から [CdrHelpers.decodeCdrString] で string を読む */
        fun decodeFromCdr(data: ByteArray): StringMessage? {
            val str = CdrHelpers.decodeCdrString(data, offset = 4) ?: return null
            return StringMessage(data = str)
        }
    }
}
