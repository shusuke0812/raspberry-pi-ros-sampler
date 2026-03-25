package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.binary

import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * クライアント → サーバーへのバイナリメッセージエンコーダ
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#binary-messages
 */
object FoxgloveBinaryMessageEncoder {

    private const val OPCODE_CLIENT_MESSAGE_DATA: Byte = 0x01
    private const val OPCODE_SERVICE_CALL_REQUEST: Byte = 0x02

    /**
     * Client Message Data（opcode 0x01）をエンコードする
     *
     * @param channelId Client Advertise で登録したチャンネル ID
     * @param payload メッセージペイロード（JSON エンコード済みなど）
     * @return 送信用バイナリデータ
     */
    fun encodeClientMessageData(channelId: UInt, payload: ByteArray): ByteArray {
        val buffer = ByteBuffer.allocate(1 + 4 + payload.size)
            .order(ByteOrder.LITTLE_ENDIAN)
        buffer.put(OPCODE_CLIENT_MESSAGE_DATA)
        buffer.putInt(channelId.toInt())
        buffer.put(payload)
        return buffer.array()
    }

    /**
     * Service Call Request（opcode 0x02）をエンコードする
     *
     * @param serviceId Advertise Services で取得したサービス ID
     * @param callId レスポンスと対応付けるための一意な ID
     * @param encoding エンコーディング名（例: "json"）
     * @param payload リクエストペイロード
     * @return 送信用バイナリデータ
     */
    fun encodeServiceCallRequest(
        serviceId: UInt,
        callId: UInt,
        encoding: String,
        payload: ByteArray,
    ): ByteArray {
        val encodingBytes = encoding.encodeToByteArray()
        val encodingLength = encodingBytes.size
        val buffer = ByteBuffer.allocate(1 + 4 + 4 + 4 + encodingLength + payload.size)
            .order(ByteOrder.LITTLE_ENDIAN)
        buffer.put(OPCODE_SERVICE_CALL_REQUEST)
        buffer.putInt(serviceId.toInt())
        buffer.putInt(callId.toInt())
        buffer.putInt(encodingLength)
        buffer.put(encodingBytes)
        buffer.put(payload)
        return buffer.array()
    }
}
