package com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove

import com.shusuke.raspberry_pi_android_client.data.infrastructure.MessageBridgeClient
import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.service.RosCallService
import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.service.RosServiceResponse
import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.RosTopicSubscribe
import kotlinx.serialization.KSerializer

/**
 * [FoxgloveBridgeClient] を [MessageBridgeClient] に適合させるアダプター。
 */
class FoxgloveMessageBridgeAdapter(
    private val foxgloveBridgeClient: FoxgloveBridgeClient,
) : MessageBridgeClient {

    override fun <T> publish(
        topic: RosTopicPublish<T>,
        messageSerializer: KSerializer<T>,
        schemaName: String,
    ) {
        foxgloveBridgeClient.publish(topic, messageSerializer, schemaName)
    }

    override fun <M> startSubscribe(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    ) {
        foxgloveBridgeClient.startSubscribe(topic, messageSerializer, onMessage)
    }

    override fun endSubscribe(topic: RosTopicSubscribe) {
        foxgloveBridgeClient.endSubscribe(topic)
    }

    override fun <A, R> callService(
        service: RosCallService<A>,
        argsSerializer: KSerializer<A>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
    ) {
        foxgloveBridgeClient.callService(service, argsSerializer, responseSerializer, onMessage)
    }
}
