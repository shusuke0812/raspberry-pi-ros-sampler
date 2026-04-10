package com.shusuke.raspberry_pi_client.data.infrastructure.ros.service

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.cdr.CdrHelpers
import kotlinx.serialization.Serializable
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * `bool ignore_this_field` を持つダミーの空サービス型。
 *
 * CDR エンコード: header(4) + bool(1) = 5 バイト
 */
@Serializable
data class DummyEmptyService(val ignore_this_field: Boolean = false) {
    companion object {
        /**
         * CDR LE バイナリにエンコードする。
         *
         * 構造: header(4) + ignore_this_field(1)
         */
        fun encodeToCdr(args: DummyEmptyService): ByteArray {
            val buffer = ByteBuffer.allocate(4 + 1).order(ByteOrder.LITTLE_ENDIAN)
            buffer.put(CdrHelpers.encapsulationHeader)
            buffer.put(if (args.ignore_this_field) 0x01.toByte() else 0x00.toByte())
            return buffer.array()
        }

        /**
         * CDR バイナリからデコードする。
         *
         * @param data CDR バイナリ（header 4 バイト + bool 1 バイト）
         * @return デコード結果。データ不足の場合はデフォルト値を返す
         */
        fun decodeFromCdr(data: ByteArray): DummyEmptyService {
            if (data.size < 5) return DummyEmptyService()
            val value = data[4] != 0x00.toByte()
            return DummyEmptyService(ignore_this_field = value)
        }
    }
}
