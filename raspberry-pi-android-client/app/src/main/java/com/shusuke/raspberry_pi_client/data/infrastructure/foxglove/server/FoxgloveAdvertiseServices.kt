package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.server

import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.common.FoxgloveMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Advertise Services メッセージ（サーバー → クライアント）
 *
 * 利用可能なサービスをクライアントに通知する。
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise-services
 */
@Serializable
data class FoxgloveAdvertiseServices(
    val op: FoxgloveMessageOperation = FoxgloveMessageOperation.AdvertiseServices,
    val services: List<FoxgloveAdvertiseService> = emptyList(),
) {
    fun serviceNameToIdMap(): Map<String, UInt> =
        services.associate { it.name to it.id }

    fun serviceNameToRequestEncodingMap(): Map<String, String> =
        services.mapNotNull { service ->
            service.request?.encoding?.let { (service.name to it) }
        }.toMap()
}

/**
 * Advertise Services メッセージ内のサービス情報（サーバー → クライアント）
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#advertise-services
 */
@Serializable
data class FoxgloveAdvertiseService(
    val id: UInt,
    val name: String,
    val type: String? = null,
    val request: FoxgloveServiceSchema? = null,
    val response: FoxgloveServiceSchema? = null,
    @SerialName("requestSchema")
    val requestSchema: String? = null,
    @SerialName("responseSchema")
    val responseSchema: String? = null,
)

/**
 * サービスのリクエスト/レスポンススキーマ
 */
@Serializable
data class FoxgloveServiceSchema(
    val encoding: String? = null,
    @SerialName("schemaName")
    val schemaName: String? = null,
    @SerialName("schemaEncoding")
    val schemaEncoding: String? = null,
    val schema: String? = null,
)
