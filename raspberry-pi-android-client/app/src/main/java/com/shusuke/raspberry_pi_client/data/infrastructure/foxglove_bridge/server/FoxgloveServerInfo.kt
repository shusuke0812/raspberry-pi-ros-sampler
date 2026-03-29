package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.server

import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common.FoxgloveMessageOperation
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Server Info メッセージ（サーバー → クライアント）
 *
 * 接続確立時にサーバーが必ず送信する。
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#server-info
 */
@Serializable
data class FoxgloveServerInfo(
    val op: FoxgloveMessageOperation = FoxgloveMessageOperation.ServerInfo,
    val name: String = "",
    val capabilities: List<String> = emptyList(),
    @SerialName("supportedEncodings")
    val supportedEncodings: List<String>? = null,
    val metadata: Map<String, String>? = null,
    @SerialName("sessionId")
    val sessionId: String? = null,
) {
    val supportsClientPublish: Boolean
        get() = capabilities.contains("clientPublish")

    val supportsServices: Boolean
        get() = capabilities.contains("services")

    val supportsJsonEncoding: Boolean
        get() = supportedEncodings?.contains("json") == true
}
