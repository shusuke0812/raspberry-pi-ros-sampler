package com.shusuke.raspberry_pi_client.data.infrastructure.websocket

import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.Request

/**
 * WebSocket 接続用の URL とリクエスト設定を保持するデータクラス。
 *
 * [rosBridge] ROS Bridge 用（ポート 9090）
 * [foxgloveBridge] Foxglove Bridge 用（ポート 8765、Sec-WebSocket-Protocol 対応）
 */
data class WebSocketUrl(
    private val ipAddress: String,
    private val port: Int,
    private val protocols: List<String>? = null,
) {
    /**
     * WebSocket 接続用の URL 文字列（ws://ip:port）
     */
    private val urlString: String
        get() = "ws://$ipAddress:$port"

    /**
     * OkHttp WebSocket 接続用の [Request.Builder]。
     * protocols が指定されている場合、Sec-WebSocket-Protocol ヘッダーを設定する。
     */
    fun toRequest(): Request.Builder {
        val builder = Request.Builder().url(urlString)
        if (!protocols.isNullOrEmpty()) {
            builder.addHeader(HEADER_WEBSOCKET_PROTOCOL, protocols.joinToString(", "))
        }
        return builder
    }

    companion object {
        private const val HEADER_WEBSOCKET_PROTOCOL = "Sec-WebSocket-Protocol"

        /**
         * ROS Bridge 用の URL（ポート 9090）
         */
        fun rosBridge(ipAddress: String): WebSocketUrl =
            WebSocketUrl(ipAddress = ipAddress, port = ROS_BRIDGE_PORT, protocols = null)

        /**
         * Foxglove Bridge 用の URL（ポート 8765）
         *
         * [subprotocol ref](https://github.com/foxglove/foxglove-sdk/blob/main/ros/src/foxglove_bridge/include/foxglove_bridge/common.hpp#L12)
         */
        fun foxgloveBridge(ipAddress: String): WebSocketUrl =
            WebSocketUrl(
                ipAddress = ipAddress,
                port = FOXGLOVE_BRIDGE_PORT,
                protocols = listOf(FOXGLOVE_BRIDGE_SUBPROTOCOL),
            )

        private const val ROS_BRIDGE_PORT = 9090
        private const val FOXGLOVE_BRIDGE_PORT = 8765
        private const val FOXGLOVE_BRIDGE_SUBPROTOCOL = "foxglove.sdk.v1"
    }
}
