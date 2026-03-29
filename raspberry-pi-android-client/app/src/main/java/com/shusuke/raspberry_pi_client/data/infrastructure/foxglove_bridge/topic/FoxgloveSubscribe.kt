package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common.FoxgloveMessageOperation
import kotlinx.serialization.Serializable

/**
 * Subscribe メッセージ（クライアント → サーバー）
 *
 * チャンネルへの購読をリクエストする。
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#subscribe
 */
@Serializable
data class FoxgloveSubscribe(
    val op: FoxgloveMessageOperation = FoxgloveMessageOperation.Subscribe,
    val subscriptions: List<FoxgloveSubscribeSubscription> = emptyList(),
)

/**
 * Subscribe メッセージ内の購読情報（クライアント → サーバー）
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#subscribe
 */
@Serializable
data class FoxgloveSubscribeSubscription(
    val id: UInt,
    val channelId: UInt,
)
