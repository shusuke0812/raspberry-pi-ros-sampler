package com.shusuke.raspberry_pi_client.data.infrastructure.ros.cdr

import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Ref: [DDS-XTypes](https://www.omg.org/spec/DDS-XTypes/)
 */
object CdrHelpers {

    /**
     * CDR カプセル化ヘッダー（4 バイト）。
     * バイト 0–1: 0x00 0x01 → CDR_LE。デコード時はこの 4 バイトをスキップしてペイロードを読む。
     */
    val encapsulationHeader: ByteArray = byteArrayOf(0x00, 0x01, 0x00, 0x00)

    /**
     * CDR string をデコードする
     *
     * @param data CDR バイナリ
     * @param offset **4 バイトの uint32 LE 長さフィールドの先頭**（string ブロックの開始位置）
     * @return UTF-8 文字列（末尾 NUL は含めない）。範囲外または不正なデータのときは null
     */
    fun decodeCdrString(data: ByteArray, offset: Int): String? {
        if (data.size < offset + 4) return null
        val length = readUInt32LittleEndian(data, offset)
        if (length == 0u) return null
        if (data.size < offset + 4 + length.toInt()) return null
        val start = offset + 4
        val end = offset + 4 + length.toInt() - 1
        val stringBytes = data.copyOfRange(start, end)
        return stringBytes.decodeToString()
    }

    /**
     * CDR string をエンコードする。
     *
     * uint32 LE 長さフィールド（null 終端を含む）＋ UTF-8 バイト列 ＋ null バイト。
     *
     * @param value エンコードする文字列
     * @return CDR string バイト列
     */
    fun encodeCdrString(value: String): ByteArray {
        val strBytes = value.encodeToByteArray()
        val length = strBytes.size + 1  // null 終端を含む長さ
        val buf = ByteBuffer.allocate(4 + length).order(ByteOrder.LITTLE_ENDIAN)
        buf.putInt(length)
        buf.put(strBytes)
        buf.put(0x00.toByte())
        return buf.array()
    }

    private fun readUInt32LittleEndian(data: ByteArray, offset: Int): UInt {
        return ByteBuffer.wrap(data, offset, 4)
            .order(ByteOrder.LITTLE_ENDIAN)
            .int
            .toUInt()
    }
}
