package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.topic

import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.common.FoxgloveMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Client Advertise メッセージ（クライアント → サーバー）
 *
 * クライアントが publish するチャンネルをサーバーに通知する。
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#client-advertise
 */
@Serializable
data class FoxgloveClientAdvertise(
    val op: FoxgloveMessageOperation = FoxgloveMessageOperation.Advertise,
    val channels: List<FoxgloveClientAdvertiseChannel> = emptyList(),
)

/**
 * Client Advertise メッセージ内のチャンネル情報（クライアント → サーバー）
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#client-advertise
 */
@Serializable
data class FoxgloveClientAdvertiseChannel(
    val id: UInt,
    val topic: String,
    val encoding: String = "json",
    @SerialName("schemaName")
    val schemaName: String,
    val schema: String? = null,
    @SerialName("schemaEncoding")
    val schemaEncoding: String? = null,
)
