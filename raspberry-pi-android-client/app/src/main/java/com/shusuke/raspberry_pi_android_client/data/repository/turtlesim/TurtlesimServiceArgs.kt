package com.shusuke.raspberry_pi_android_client.data.repository.turtlesim

import kotlinx.serialization.Serializable

/**
 * turtlesim の `/spawn` サービスの引数
 */
@Serializable
data class TurtlesimServiceArgs(
    val x: Float = 0f,
    val y: Float = 0f,
    val theta: Float = 0f,
    val name: String? = null
)
