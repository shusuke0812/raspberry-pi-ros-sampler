package com.shusuke.raspberry_pi_client.data.repository.hello

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicSubscribe
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message.Int8Message
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message.StringMessage
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicError
import com.shusuke.raspberry_pi_client.data.repository.connection.RosConnectionRepository
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

/**
 * `/hello` および `/hello_signal` トピックを購読するリポジトリ。
 *
 * - [subscribeHello] → `/hello` (std_msgs/msg/String)
 * - [subscribeHelloSignal] → `/hello_signal` (std_msgs/msg/Int8)
 */
class HelloTopicRepository(
    private val connectionRepository: RosConnectionRepository,
) {
    private val helloTopic = RosTopicSubscribe(
        topic = "/hello",
        messageType = "std_msgs/msg/String",
    )
    private val helloSignalTopic = RosTopicSubscribe(
        topic = "/hello_signal",
        messageType = "std_msgs/msg/Int8",
    )

    /**
     * `/hello` トピックの購読を開始する。
     *
     * @return [HelloTopicResponse]（[RosTopicPublish]&lt;[StringMessage]&gt;）の Flow。
     *         エラー時は [RosTopicError] を emit する。
     */
    fun subscribeHello(): Flow<Result<HelloTopicResponse>> = callbackFlow {
        val client = connectionRepository.activeMessageClient
        client.startSubscribe(
            topic = helloTopic,
            messageSerializer = StringMessage.serializer(),
            onMessage = { result ->
                result.fold(
                    onSuccess = { trySend(Result.success(it as HelloTopicResponse)) },
                    onFailure = { trySend(Result.failure(it as RosTopicError)) },
                )
            },
        )
        awaitClose { client.endSubscribe(helloTopic) }
    }

    /**
     * `/hello` トピックの購読を終了する。
     */
    fun unsubscribeHello() {
        connectionRepository.activeMessageClient.endSubscribe(helloTopic)
    }

    /**
     * `/hello_signal` トピックの購読を開始する。
     *
     * @return [HelloSignalTopicResponse]（[RosTopicPublish]&lt;[Int8Message]&gt;）の Flow。
     *         エラー時は [RosTopicError] を emit する。
     */
    fun subscribeHelloSignal(): Flow<Result<HelloSignalTopicResponse>> = callbackFlow {
        val client = connectionRepository.activeMessageClient
        client.startSubscribe(
            topic = helloSignalTopic,
            messageSerializer = Int8Message.serializer(),
            onMessage = { result ->
                result.fold(
                    onSuccess = { trySend(Result.success(it as HelloSignalTopicResponse)) },
                    onFailure = { trySend(Result.failure(it as RosTopicError)) },
                )
            },
        )
        awaitClose { client.endSubscribe(helloSignalTopic) }
    }

    /**
     * `/hello_signal` トピックの購読を終了する。
     */
    fun unsubscribeHelloSignal() {
        connectionRepository.activeMessageClient.endSubscribe(helloSignalTopic)
    }
}

/** [RosTopicPublish]&lt;[StringMessage]&gt; の型エイリアス */
typealias HelloTopicResponse = RosTopicPublish<StringMessage>

/** [RosTopicPublish]&lt;[Int8Message]&gt; の型エイリアス */
typealias HelloSignalTopicResponse = RosTopicPublish<Int8Message>
