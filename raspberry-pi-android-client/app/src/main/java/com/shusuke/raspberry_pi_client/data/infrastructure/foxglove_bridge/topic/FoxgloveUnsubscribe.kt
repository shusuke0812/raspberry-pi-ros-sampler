package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common.FoxgloveMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Unsubscribe メッセージ（クライアント → サーバー）
 *
 * 購読の停止をリクエストする。
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#unsubscribe
 */
@Serializable
data class FoxgloveUnsubscribe(
    val op: FoxgloveMessageOperation = FoxgloveMessageOperation.Unsubscribe,
    @SerialName("subscriptionIds")
    val subscriptionIds: List<UInt> = emptyList(),
)
