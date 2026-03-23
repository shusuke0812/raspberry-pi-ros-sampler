package com.shusuke.raspberry_pi_android_client.data.infrastructure.websocket

/**
 * WebSocket 接続状態を表す sealed class。
 */
sealed class WebSocketConnectionState {
    /**
     * 未接続（初期状態）
     */
    data object Ready : WebSocketConnectionState()

    /**
     * 接続中
     */
    data object Connecting : WebSocketConnectionState()

    /**
     * 接続済み
     */
    data object Connected : WebSocketConnectionState()

    /**
     * 切断
     *
     * @param closeCode WebSocket のクローズコード（1000 = Normal Closure など）
     * @param reason 切断理由（UTF-8 でデコード可能な場合の文字列）
     */
    data class Disconnected(
        val closeCode: Int,
        val reason: String?,
    ) : WebSocketConnectionState()

    /**
     * 接続タイムアウト
     */
    data object ConnectingTimeout : WebSocketConnectionState()

    /**
     * UI 表示用の説明文字列
     */
    val description: String
        get() = when (this) {
            is Ready -> "未接続"
            is Connecting -> "接続中..."
            is Connected -> "接続"
            is Disconnected -> {
                val reasonPart = if (reason != null) "\n$reason" else ""
                "切断(code: $closeCode)$reasonPart"
            }
            is ConnectingTimeout -> "接続タイムアウトエラー"
        }
}
