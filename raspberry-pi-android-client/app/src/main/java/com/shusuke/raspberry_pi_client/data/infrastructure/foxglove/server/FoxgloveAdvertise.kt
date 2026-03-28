package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.server

import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.common.FoxgloveMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Advertise メッセージ（サーバー → クライアント）
 *
 * 利用可能なチャンネル（トピック）をクライアントに通知する。
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise
 */
@Serializable
data class FoxgloveAdvertise(
    val op: FoxgloveMessageOperation = FoxgloveMessageOperation.Advertise,
    val channels: List<FoxgloveAdvertiseChannel> = emptyList(),
) {
    fun topicToChannelIdMap(): Map<String, UInt> =
        channels.associate { it.topic to it.id }

    fun topicToEncodingMap(): Map<String, String> =
        channels.associate { it.topic to it.encoding }
}

/**
 * Advertise メッセージ内のチャンネル情報（サーバー → クライアント）
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise
 */
@Serializable
data class FoxgloveAdvertiseChannel(
    val id: UInt,
    val topic: String,
    val encoding: String,
    @SerialName("schemaName")
    val schemaName: String,
    val schema: String,
    @SerialName("schemaEncoding")
    val schemaEncoding: String? = null,
)
