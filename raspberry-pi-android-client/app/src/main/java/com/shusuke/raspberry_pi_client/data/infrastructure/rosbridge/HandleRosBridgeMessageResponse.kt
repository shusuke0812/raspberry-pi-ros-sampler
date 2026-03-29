package com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge

import kotlinx.serialization.Serializable

/**
 * RosBridgeClient のメッセージレスポンスの種別を判別するために使用する.
 * 判別した後、`publish`, `serviceResponse` 毎にデコード処理を行う.
 */
@Serializable
data class HandleRosBridgeMessageResponse(
    val op: RosBridgeMessageOperation
) {
    fun toHandleOperation(): HandleRosBridgeMessageOperation? =
        when (op) {
            RosBridgeMessageOperation.publish -> HandleRosBridgeMessageOperation.Publish
            RosBridgeMessageOperation.serviceResponse -> HandleRosBridgeMessageOperation.ServiceResponse
            else -> null
        }
}

/**
 * デコード対象の RosBridge メッセージ種別
 */
enum class HandleRosBridgeMessageOperation {
    Publish,
    ServiceResponse
}
