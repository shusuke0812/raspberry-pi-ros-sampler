package com.shusuke.raspberry_pi_client.data.infrastructure

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosCallService
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceResponse
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicSubscribe
import kotlinx.serialization.KSerializer

/**
 * ROS Bridge / Foxglove Bridge に共通するメッセージ操作インターフェース。
 *
 * [RosBridgeClient] と [FoxgloveBridgeClient] の差異を吸収し、
 * Repository 層から透過的に publish / subscribe / callService を呼び出す。
 */
interface MessageBridgeClient {
    /**
     * トピックにメッセージを publish する。
     *
     * @param schemaName ROS スキーマ名（例: "std_msgs/msg/String"）。RosBridge では未使用。
     */
    fun <T> publish(
        topic: RosTopicPublish<T>,
        messageSerializer: KSerializer<T>,
        schemaName: String,
    )

    /**
     * トピックの購読を開始する。
     */
    fun <M> startSubscribe(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    )

    /**
     * トピックの購読を終了する。
     */
    fun endSubscribe(topic: RosTopicSubscribe)

    /**
     * ROS サービスを呼び出す。
     *
     * @param cdrEncoder CDR エンコード関数。Foxglove Bridge が CDR を要求した場合に使用される。
     * @param cdrResponseDecoder CDR レスポンスデコード関数。Foxglove Bridge から CDR レスポンスを受信した場合に使用される。
     */
    fun <A, R> callService(
        service: RosCallService<A>,
        argsSerializer: KSerializer<A>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
        cdrEncoder: ((A) -> ByteArray)? = null,
        cdrResponseDecoder: ((ByteArray) -> R)? = null,
    )
}
