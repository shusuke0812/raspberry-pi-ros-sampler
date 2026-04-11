package com.shusuke.raspberry_pi_client.data.infrastructure.ros.service

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.cdr.CdrHelpers
import kotlinx.serialization.Serializable
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * `uint32 ignoreThisField` を持つダミーの空サービス型。
 *
 * CDR エンコード: header(4) + uint32(4) = 8 バイト
 */
@Serializable
data class DummyEmptyService(val ignoreThisField: UInt = 0u) {
    companion object {
        /**
         * CDR LE バイナリにエンコードする。
         *
         * 構造: header(4) + ignoreThisField(4)
         */
        fun encodeToCdr(args: DummyEmptyService): ByteArray {
            val buffer = ByteBuffer.allocate(4 + 4).order(ByteOrder.LITTLE_ENDIAN)
            buffer.put(CdrHelpers.encapsulationHeader)
            buffer.putInt(args.ignoreThisField.toInt())
            return buffer.array()
        }

        /**
         * CDR バイナリからデコードする。
         *
         * @param data CDR バイナリ（header 4 バイト + uint32 4 バイト）
         * @return デコード結果。データ不足の場合はデフォルト値を返す
         */
        fun decodeFromCdr(data: ByteArray): DummyEmptyService {
            if (data.size < 8) return DummyEmptyService()
            val value = ByteBuffer.wrap(data, 4, 4).order(ByteOrder.LITTLE_ENDIAN).int.toUInt()
            return DummyEmptyService(ignoreThisField = value)
        }
    }
}
