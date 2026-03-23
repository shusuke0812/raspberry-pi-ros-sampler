package com.shusuke.raspberry_pi_android_client.data.repository.connection

/**
 * 接続先の Bridge 種別
 */
enum class ConnectionMode(val displayName: String) {
    ROS_BRIDGE(displayName = "ROS Bridge"),
    FOXGLOVE_BRIDGE(displayName = "Foxglove Bridge");
}
