package com.shusuke.raspberry_pi_client.data.infrastructure.util

object BinaryLogHelpers {

    /**
     * ByteArray を16進数文字列に変換する。
     * 例: byteArrayOf(0x01, 0xAB, 0xFF) → "01 AB FF"
     */
    fun toHexString(data: ByteArray): String =
        data.joinToString(" ") { "%02X".format(it) }
}
