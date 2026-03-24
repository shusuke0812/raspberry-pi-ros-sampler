package com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove.common

import com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove.server.FoxgloveAdvertise
import com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove.server.FoxgloveAdvertiseServices
import com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove.server.FoxgloveServerInfo
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

/**
 * Foxglove JSON メッセージのパーサ（サーバー → クライアント）
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md
 */
object FoxgloveJsonMessageParser {

    private val json = Json {
        ignoreUnknownKeys = true
    }

    /**
     * JSON 文字列をパースしてメッセージ種別に応じた結果を返す
     *
     * @param jsonString 受信した JSON 文字列
     * @return パース結果。パースに失敗した場合は null
     */
    fun parseServerMessage(jsonString: String): FoxgloveServerJsonMessage? =
        runCatching {
            val header = json.decodeFromString<FoxgloveMessageHeader>(jsonString)
            val op = FoxgloveMessageOperation.fromWireString(header.op)
                ?: return@runCatching FoxgloveServerJsonMessage.Other
            when (op) {
                FoxgloveMessageOperation.ServerInfo ->
                    FoxgloveServerJsonMessage.ServerInfo(
                        json.decodeFromString<FoxgloveServerInfo>(jsonString),
                    )
                FoxgloveMessageOperation.Advertise ->
                    FoxgloveServerJsonMessage.Advertise(
                        json.decodeFromString<FoxgloveAdvertise>(jsonString),
                    )
                FoxgloveMessageOperation.Unadvertise ->
                    FoxgloveServerJsonMessage.Unadvertise(
                        json.decodeFromString<FoxgloveUnadvertiseBody>(jsonString).channelIds,
                    )
                FoxgloveMessageOperation.AdvertiseServices ->
                    FoxgloveServerJsonMessage.AdvertiseServices(
                        json.decodeFromString<FoxgloveAdvertiseServices>(jsonString),
                    )
                FoxgloveMessageOperation.UnadvertiseServices ->
                    FoxgloveServerJsonMessage.UnadvertiseServices(
                        json.decodeFromString<FoxgloveUnadvertiseServicesBody>(jsonString).serviceIds,
                    )
                FoxgloveMessageOperation.ServiceCallFailure ->
                    json.decodeFromString<FoxgloveServiceCallFailureBody>(jsonString).let { body ->
                        FoxgloveServerJsonMessage.ServiceCallFailure(
                            serviceId = body.serviceId,
                            callId = body.callId,
                            message = body.message,
                        )
                    }
                FoxgloveMessageOperation.Subscribe,
                FoxgloveMessageOperation.Unsubscribe,
                -> FoxgloveServerJsonMessage.Other
            }
        }.getOrNull()

    val jsonInstance: Json get() = json
}

/**
 * サーバーから受信した JSON メッセージのパース結果
 */
sealed class FoxgloveServerJsonMessage {
    data class ServerInfo(val info: FoxgloveServerInfo) : FoxgloveServerJsonMessage()
    data class Advertise(val advertise: FoxgloveAdvertise) : FoxgloveServerJsonMessage()
    data class Unadvertise(val channelIds: List<UInt>) : FoxgloveServerJsonMessage()
    data class AdvertiseServices(val services: FoxgloveAdvertiseServices) : FoxgloveServerJsonMessage()
    data class UnadvertiseServices(val serviceIds: List<UInt>) : FoxgloveServerJsonMessage()
    data class ServiceCallFailure(
        val serviceId: UInt,
        val callId: UInt,
        val message: String,
    ) : FoxgloveServerJsonMessage()
    data object Other : FoxgloveServerJsonMessage()
}

@Serializable
private data class FoxgloveMessageHeader(val op: String)

@Serializable
private data class FoxgloveUnadvertiseBody(
    @SerialName("channelIds")
    val channelIds: List<UInt>,
)

@Serializable
private data class FoxgloveUnadvertiseServicesBody(
    @SerialName("serviceIds")
    val serviceIds: List<UInt>,
)

@Serializable
private data class FoxgloveServiceCallFailureBody(
    @SerialName("serviceId")
    val serviceId: UInt,
    @SerialName("callId")
    val callId: UInt,
    val message: String,
)
