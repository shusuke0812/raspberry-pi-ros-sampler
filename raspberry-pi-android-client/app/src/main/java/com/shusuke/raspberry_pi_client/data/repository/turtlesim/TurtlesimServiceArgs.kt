package com.shusuke.raspberry_pi_client.data.repository.turtlesim

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.cdr.CdrHelpers
import kotlinx.serialization.Serializable
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * turtlesim の `/spawn` サービスの引数
 */
@Serializable
data class TurtlesimServiceArgs(
    val x: Float = 0f,
    val y: Float = 0f,
    val theta: Float = 0f,
    val name: String? = null
) {
    companion object {
        /**
         * CDR LE バイナリにエンコードする。
         *
         * 構造: header(4) + x(4) + y(4) + theta(4) + name(CDR string)
         */
        fun encodeToCdr(args: TurtlesimServiceArgs): ByteArray {
            val nameEncoded = CdrHelpers.encodeCdrString(args.name ?: "")
            val buffer = ByteBuffer.allocate(4 + 4 + 4 + 4 + nameEncoded.size)
                .order(ByteOrder.LITTLE_ENDIAN)
            buffer.put(CdrHelpers.encapsulationHeader)
            buffer.putFloat(args.x)
            buffer.putFloat(args.y)
            buffer.putFloat(args.theta)
            buffer.put(nameEncoded)
            return buffer.array()
        }
    }
}
