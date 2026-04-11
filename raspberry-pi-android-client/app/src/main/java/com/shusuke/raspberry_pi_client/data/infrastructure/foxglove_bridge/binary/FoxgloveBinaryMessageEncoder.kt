package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.binary

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
     * データ形式 [opcode 1Byte][channelId 4Byte][payload NByte]
     *
     * @param channelId Client Advertise で登録したチャンネル ID
     * @param payload メッセージペイロード（CDR エンコード済みなど）
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
     * データ形式 [opcode 1Byte][serviceId 4Byte][callId 4Byte][encoding length 4Byte][payload NByte]
     *
     * @param serviceId Advertise Services で取得したサービス ID（/spawn のようなサービス名を識別するID）
     * @param callId レスポンスと対応付けるための一意な ID（各リクエストごとに発行されるID、同じサービスが複数回呼ばれても良いようにリクエスト・レスポンスを紐づけるためのID）
     * @param encoding エンコーディング名（"json", "cdr"）
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
