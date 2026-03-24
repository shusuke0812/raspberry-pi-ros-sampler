package com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove.common

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Foxglove WebSocket プロトコルの JSON メッセージ種別（op フィールド）
 *
 * [wireValue] は JSON の "op" 文字列と一致する（[fromWireString] で逆引きする）。
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md
 */
@Serializable
enum class FoxgloveMessageOperation(val wireValue: String) {
    @SerialName("serverInfo")
    ServerInfo("serverInfo"),

    @SerialName("advertise")
    Advertise("advertise"),

    @SerialName("unadvertise")
    Unadvertise("unadvertise"),

    @SerialName("advertiseServices")
    AdvertiseServices("advertiseServices"),

    @SerialName("unadvertiseServices")
    UnadvertiseServices("unadvertiseServices"),

    @SerialName("serviceCallFailure")
    ServiceCallFailure("serviceCallFailure"),

    @SerialName("subscribe")
    Subscribe("subscribe"),

    @SerialName("unsubscribe")
    Unsubscribe("unsubscribe");

    companion object {
        private val wireValueToOperation: Map<String, FoxgloveMessageOperation> =
            entries.associateBy { it.wireValue }

        /**
         * JSON の "op" 文字列から [FoxgloveMessageOperation] を解決する。
         * 未知の値は null。
         */
        fun fromWireString(value: String): FoxgloveMessageOperation? =
            wireValueToOperation[value]
    }
}
