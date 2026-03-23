package com.shusuke.raspberry_pi_android_client.data.repository.turtlesim

import kotlinx.serialization.Serializable

/**
 * turtlesim の `/spawn` サービスのレスポンス
 */
@Serializable
data class TurtlesimServiceResponse(
    val name: String = ""
)
