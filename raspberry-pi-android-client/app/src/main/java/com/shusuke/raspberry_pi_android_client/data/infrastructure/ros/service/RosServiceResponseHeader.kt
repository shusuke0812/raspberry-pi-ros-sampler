package com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.service

import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.RosBridgeMessageOperation
import kotlinx.serialization.Serializable

/**
 * RosBridge の service_response メッセージのヘッダー（ルーティング用）
 *
 * 受信メッセージから service を判別し、適切なハンドラに振り分けるために使用する。
 */
@Serializable
internal data class RosServiceResponseHeader(
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.serviceResponse,
    val id: String? = null,
    val service: String,
    val result: Boolean = true,
)
