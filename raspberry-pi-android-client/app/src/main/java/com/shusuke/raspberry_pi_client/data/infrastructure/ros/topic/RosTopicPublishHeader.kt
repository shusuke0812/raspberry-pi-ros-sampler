package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.RosBridgeMessageOperation
import kotlinx.serialization.Serializable

/**
 * RosBridge の publish メッセージのヘッダー（ルーティング用）
 *
 * 受信メッセージから topic を判別し、適切なハンドラに振り分けるために使用する。
 */
@Serializable
internal data class RosTopicPublishHeader(
    val id: String? = null,
    val op: RosBridgeMessageOperation = RosBridgeMessageOperation.publish,
    val topic: String,
)
