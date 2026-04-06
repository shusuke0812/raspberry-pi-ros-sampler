package com.shusuke.raspberry_pi_client.data.repository.turtlesim

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.cdr.CdrHelpers
import kotlinx.serialization.Serializable

/**
 * turtlesim の `/spawn` サービスのレスポンス
 */
@Serializable
data class TurtlesimServiceResponse(
    val name: String = ""
) {
    companion object {
        /**
         * CDR LE バイナリからデコードする。
         *
         * 構造: header(4) + name(CDR string)
         *
         * @return デコード成功時は [TurtlesimServiceResponse]、失敗時は null
         */
        fun decodeFromCdr(payload: ByteArray): TurtlesimServiceResponse? {
            if (payload.size < 4) return null
            val name = CdrHelpers.decodeCdrString(payload, 4) ?: ""
            return TurtlesimServiceResponse(name = name)
        }
    }
}
