package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.binary

import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Foxglove バイナリメッセージのパーサ（サーバー → クライアント）
 *
 * Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md#binary-messages
 */
object FoxgloveBinaryMessageParser {

    private const val OPCODE_MESSAGE_DATA: Byte = 0x01
    private const val OPCODE_SERVICE_CALL_RESPONSE: Byte = 0x03

    /**
     * サーバーから受信したバイナリデータをパースする
     *
     * @param data 受信したバイナリデータ（1バイト目が opcode）
     * @return パース結果
     */
    fun parseServerMessage(data: ByteArray): FoxgloveServerBinaryMessage {
        if (data.isEmpty()) {
            return FoxgloveServerBinaryMessage.Unknown(opcode = 0, error = FoxgloveBinaryParseError.InsufficientData)
        }
        val opcode = data[0]
        val payload = data.copyOfRange(1, data.size)
        return when (opcode) {
            OPCODE_MESSAGE_DATA -> parseMessageData(payload)
            OPCODE_SERVICE_CALL_RESPONSE -> parseServiceCallResponse(payload)
            else -> FoxgloveServerBinaryMessage.Unknown(opcode = opcode.toInt().and(0xFF).toByte(), error = null)
        }
    }

    /**
     * Message Data（opcode 0x01）
     * | 4 bytes: subscription id (uint32) |
     * | 8 bytes: timestamp (uint64) |
     * | remaining: payload |
     */
    private fun parseMessageData(data: ByteArray): FoxgloveServerBinaryMessage {
        if (data.size < 12) {
            return FoxgloveServerBinaryMessage.Unknown(opcode = OPCODE_MESSAGE_DATA, error = FoxgloveBinaryParseError.InsufficientData)
        }
        val buffer = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN)
        val subscriptionId = buffer.int.toUInt() //and 0xFFFFFFFFu
        val timestamp = buffer.long
        val payload = data.copyOfRange(12, data.size)
        return FoxgloveServerBinaryMessage.MessageData(
            subscriptionId = subscriptionId,
            timestamp = timestamp,
            payload = payload,
        )
    }

    /**
     * Service Call Response（opcode 0x03）
     * | 4 bytes: service id (uint32) |
     * | 4 bytes: call id (uint32) |
     * | 4 bytes: encoding length (uint32) |
     * | encoding length bytes: encoding (char[]) |
     * | remaining: payload |
     */
    private fun parseServiceCallResponse(data: ByteArray): FoxgloveServerBinaryMessage {
        if (data.size < 12) {
            return FoxgloveServerBinaryMessage.Unknown(opcode = OPCODE_SERVICE_CALL_RESPONSE, error = FoxgloveBinaryParseError.InsufficientData)
        }
        val buffer = ByteBuffer.wrap(data).order(ByteOrder.LITTLE_ENDIAN)
        val serviceId = buffer.int.toUInt() and 0xFFFFFFFFu
        val callId = buffer.int.toUInt() and 0xFFFFFFFFu
        val encodingLength = buffer.int and 0x7FFFFFFF
        if (data.size < 12 + encodingLength) {
            return FoxgloveServerBinaryMessage.Unknown(opcode = OPCODE_SERVICE_CALL_RESPONSE, error = FoxgloveBinaryParseError.InsufficientData)
        }
        val encoding = data.copyOfRange(12, 12 + encodingLength).decodeToString()
        val payload = data.copyOfRange(12 + encodingLength, data.size)
        return FoxgloveServerBinaryMessage.ServiceCallResponse(
            serviceId = serviceId,
            callId = callId,
            encoding = encoding,
            payload = payload,
        )
    }
}

/**
 * サーバーから受信したバイナリメッセージのパース結果
 */
sealed class FoxgloveServerBinaryMessage {
    data class MessageData(
        val subscriptionId: UInt,
        val timestamp: Long,
        val payload: ByteArray,
    ) : FoxgloveServerBinaryMessage() {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false
            other as MessageData
            if (subscriptionId != other.subscriptionId) return false
            if (timestamp != other.timestamp) return false
            return payload.contentEquals(other.payload)
        }

        override fun hashCode(): Int {
            var result = subscriptionId.hashCode()
            result = 31 * result + timestamp.hashCode()
            result = 31 * result + payload.contentHashCode()
            return result
        }
    }

    data class ServiceCallResponse(
        val serviceId: UInt,
        val callId: UInt,
        val encoding: String,
        val payload: ByteArray,
    ) : FoxgloveServerBinaryMessage() {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false
            other as ServiceCallResponse
            if (serviceId != other.serviceId) return false
            if (callId != other.callId) return false
            if (encoding != other.encoding) return false
            return payload.contentEquals(other.payload)
        }

        override fun hashCode(): Int {
            var result = serviceId.hashCode()
            result = 31 * result + callId.hashCode()
            result = 31 * result + encoding.hashCode()
            result = 31 * result + payload.contentHashCode()
            return result
        }
    }

    data class Unknown(
        val opcode: Byte,
        val error: FoxgloveBinaryParseError?,
    ) : FoxgloveServerBinaryMessage()
}

enum class FoxgloveBinaryParseError {
    InsufficientData,
    InvalidEncoding,
}
