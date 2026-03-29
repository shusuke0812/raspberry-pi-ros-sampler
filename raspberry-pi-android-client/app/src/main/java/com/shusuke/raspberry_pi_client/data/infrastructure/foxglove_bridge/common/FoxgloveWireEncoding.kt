package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common

/**
 * Foxglove WebSocket プロトコル上のメッセージ encoding（ワイヤ名）。
 *
 * 既知の種別は [Json] / [Cdr] で表し、それ以外は [Unsupported] に保持する。
 * ワイヤに載せる文字列（小文字の `"json"` / `"cdr"` 等）はこの型にのみ閉じ込める。
 */
sealed class FoxgloveWireEncoding {

    abstract val wireName: String

    data object Json : FoxgloveWireEncoding() {
        override val wireName: String = WIRE_JSON
    }

    data object Cdr : FoxgloveWireEncoding() {
        override val wireName: String = WIRE_CDR
    }

    data class Unsupported(val raw: String) : FoxgloveWireEncoding() {
        override val wireName: String get() = raw
    }

    companion object {
        private const val WIRE_JSON = "json"
        private const val WIRE_CDR = "cdr"

        fun parse(raw: String): FoxgloveWireEncoding =
            when (raw.lowercase()) {
                WIRE_JSON -> Json
                WIRE_CDR -> Cdr
                else -> Unsupported(raw)
            }
    }
}
