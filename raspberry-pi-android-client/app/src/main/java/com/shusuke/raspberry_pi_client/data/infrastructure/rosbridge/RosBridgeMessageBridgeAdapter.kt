package com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge

import com.shusuke.raspberry_pi_client.data.infrastructure.MessageBridgeClient
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosCallService
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceResponse
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicSubscribe
import kotlinx.serialization.KSerializer

/**
 * [RosBridgeClient] を [MessageBridgeClient] に適合させるアダプター。
 *
 * schemaName は RosBridge では未使用のため無視する。
 */
class RosBridgeMessageBridgeAdapter(
    private val rosBridgeClient: RosBridgeClient,
) : MessageBridgeClient {

    override fun <T> publish(
        topic: RosTopicPublish<T>,
        messageSerializer: KSerializer<T>,
        schemaName: String,
    ) {
        rosBridgeClient.publish(topic, messageSerializer)
    }

    override fun <M> startSubscribe(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    ) {
        rosBridgeClient.startSubscribe(topic, messageSerializer, onMessage)
    }

    override fun endSubscribe(topic: RosTopicSubscribe) {
        rosBridgeClient.endSubscribe(topic)
    }

    override fun <A, R> callService(
        service: RosCallService<A>,
        argsSerializer: KSerializer<A>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
        cdrEncoder: ((A) -> ByteArray)?,
        cdrResponseDecoder: ((ByteArray) -> R)?,
    ) {
        rosBridgeClient.callService(service, argsSerializer, responseSerializer, onMessage)
    }
}
