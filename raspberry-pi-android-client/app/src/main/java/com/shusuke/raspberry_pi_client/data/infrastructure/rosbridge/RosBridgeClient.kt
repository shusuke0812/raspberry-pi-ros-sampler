package com.shusuke.raspberry_pi_client.data.infrastructure.rosbridge

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosCallService
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceError
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceResponse
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceResponseHeader
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicError
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublishHeader
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicSubscribe
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicUnsubscribe
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketClient
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketConnectionState
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketUrl
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import kotlin.Result
import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.Json

class RosBridgeClient(
    private val webSocketClient: WebSocketClient,
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    private val topicMessageHandlers =
        mutableMapOf<String, MutableList<(Result<String>) -> Unit>>()
    private val serviceMessageHandlers =
        mutableMapOf<String, MutableList<(Result<String>) -> Unit>>()

    init {
        observeReceivedMessage()
    }

    // region Connection

    /**
     * ROS Bridge に接続する。
     *
     * @param ipAddress 接続先 IP アドレス（例: "192.168.1.100"）
     */
    fun connect(ipAddress: String) {
        val url = WebSocketUrl.rosBridge(ipAddress)
        webSocketClient.connect(url)
    }

    /** ROS Bridge を切断する。 */
    fun disconnect() {
        topicMessageHandlers.clear()
        serviceMessageHandlers.clear()
        webSocketClient.disconnect()
        // textMessages の collect はキャンセルしない。キャンセルすると再接続後に
        // 受信ループが動かず subscribe してもメッセージが届かない。
    }

    /**
     * 接続状態の Flow。
     */
    fun observeConnectionState(): Flow<WebSocketConnectionState> =
        webSocketClient.connectionState

    // endregion

    // region Publish

    /**
     * トピックにメッセージを publish する。
     *
     * @param topic op=publish の [RosTopicPublish]
     */
    internal fun <T> publish(
        topic: RosTopicPublish<T>,
        messageSerializer: KSerializer<T>,
    ) {
        if (topic.op != RosBridgeMessageOperation.publish) return

        val jsonString = runCatching {
            json.encodeToString(RosTopicPublish.serializer(messageSerializer), topic)
        }.getOrNull() ?: return

        webSocketClient.send(jsonString)
    }

    // endregion

    // region Subscribe

    /**
     * トピックの購読を開始する。
     *
     * すでに購読済みの場合は [RosTopicError.AlreadySubscribed] を即座にコールバックする。
     *
     * @param topic 購読するトピック（[RosTopicSubscribe]）
     * @param onMessage メッセージ受信時のコールバック（[RosTopicPublish] または [RosTopicError]）
     */
    internal fun <M> startSubscribe(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    ) {
        if (topicMessageHandlers.containsKey(topic.topic)) {
            onMessage(Result.failure(RosTopicError.AlreadySubscribed))
            return
        }
        subscribe(topic, messageSerializer, onMessage)
    }

    /**
     * トピックの購読を終了する。
     *
     * @param topic 購読を終了するトピック（[startSubscribe] で渡したものと同じ）
     */
    fun endSubscribe(topic: RosTopicSubscribe) {
        if (!topicMessageHandlers.containsKey(topic.topic)) return

        val unsubscribe = RosTopicUnsubscribe(
            id = topic.id,
            topic = topic.topic,
        )
        unsubscribe(unsubscribe)
    }

    private fun <M> subscribe(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    ) {
        if (topic.op != RosBridgeMessageOperation.subscribe) return

        val topicJsonString = runCatching {
            json.encodeToString(RosTopicSubscribe.serializer(), topic)
        }.getOrNull() ?: return

        webSocketClient.send(topicJsonString)
        registerSubscriber(topic, messageSerializer, onMessage)
    }

    private fun unsubscribe(topic: RosTopicUnsubscribe) {
        if (topic.op != RosBridgeMessageOperation.unsubscribe) return

        val topicJsonString = runCatching {
            json.encodeToString(RosTopicUnsubscribe.serializer(), topic)
        }.getOrNull() ?: return

        webSocketClient.send(topicJsonString)
        deregisterSubscriber(topic)
    }

    private fun <M> registerSubscriber(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    ) {
        val publishSerializer = RosTopicPublish.serializer(messageSerializer)
        val handler: (Result<String>) -> Unit = { result ->
            when (val value = result.getOrNull()) {
                null -> onMessage(Result.failure((result.exceptionOrNull() as? RosTopicError)!!))
                else -> {
                    if (topicMatches(topic, value)) {
                        runCatching { json.decodeFromString(publishSerializer, value) }
                            .onSuccess { decoded -> onMessage(Result.success(decoded)) }
                            .onFailure { e -> onMessage(Result.failure(RosTopicError.FailedDecodeMessage(e))) }
                    }
                }
            }
        }
        topicMessageHandlers[topic.topic] = mutableListOf(handler)
    }

    private fun topicMatches(topic: RosTopicSubscribe, rawMessage: String): Boolean {
        val header = runCatching {
            json.decodeFromString<RosTopicPublishHeader>(rawMessage)
        }.getOrNull() ?: return false
        if (header.topic != topic.topic) return false
        if (topic.id != null && header.id != topic.id) return false
        return true
    }

    private fun deregisterSubscriber(topic: RosTopicUnsubscribe) {
        topicMessageHandlers.remove(topic.topic)
    }

    private fun handleTopic(message: String) {
        val header = runCatching {
            json.decodeFromString<RosTopicPublishHeader>(message)
        }.getOrNull() ?: return

        topicMessageHandlers[header.topic]?.forEach { handler ->
            handler(Result.success(message))
        }
    }

    // endregion

    // region Service

    /**
     * ROS サービスを呼び出す。
     *
     * すでに同じサービスを呼び出し中の場合は [RosServiceError.AlreadyCalling] を即座にコールバックする。
     *
     * @param service 呼び出すサービス（[RosCallService]）
     * @param onMessage レスポンス受信時のコールバック（[RosServiceResponse] または [RosServiceError]）
     */
    internal fun <A, R> callService(
        service: RosCallService<A>,
        argsSerializer: KSerializer<A>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
    ) {
        if (serviceMessageHandlers.containsKey(service.service)) {
            onMessage(Result.failure(RosServiceError.AlreadyCalling))
            return
        }
        call(service, argsSerializer, responseSerializer, onMessage)
    }

    private fun <A, R> call(
        service: RosCallService<A>,
        argsSerializer: KSerializer<A>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
    ) {
        if (service.op != RosBridgeMessageOperation.callService) return

        val requestJsonString = runCatching {
            json.encodeToString(RosCallService.serializer(argsSerializer), service)
        }.getOrNull() ?: return

        webSocketClient.send(requestJsonString)
        registerService(service, responseSerializer, onMessage)
    }

    private fun <R> registerService(
        service: RosCallService<*>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
    ) {
        val handler: (Result<String>) -> Unit = { result ->
            when (val value = result.getOrNull()) {
                null -> onMessage(Result.failure((result.exceptionOrNull() as? RosServiceError)!!))
                else -> {
                    if (serviceMatches(service, value)) {
                        runCatching { json.decodeFromString(responseSerializer, value) }
                            .onSuccess { decoded -> onMessage(Result.success(decoded)) }
                            .onFailure { e -> onMessage(Result.failure(RosServiceError.FailedDecodeMessage(e))) }
                    }
                }
            }
        }
        serviceMessageHandlers[service.service] = mutableListOf(handler)
    }

    private fun serviceMatches(service: RosCallService<*>, rawMessage: String): Boolean {
        val header = runCatching {
            json.decodeFromString<RosServiceResponseHeader>(rawMessage)
        }.getOrNull() ?: return false
        if (header.service != service.service) return false
        if (service.id != null && header.id != service.id) return false
        return true
    }

    private fun handleService(message: String) {
        val header = runCatching {
            json.decodeFromString<RosServiceResponseHeader>(message)
        }.getOrNull() ?: return

        val handlers = serviceMessageHandlers.remove(header.service) ?: return
        handlers.forEach { handler ->
            handler(Result.success(message))
        }
    }

    // endregion

    // region Message routing

    private fun observeReceivedMessage() {
        scope.launch {
            webSocketClient.textMessages.collect { message ->
                val header = runCatching {
                    json.decodeFromString<HandleRosBridgeMessageResponse>(message)
                }.getOrNull() ?: return@collect

                when (header.toHandleOperation()) {
                    HandleRosBridgeMessageOperation.Publish -> handleTopic(message)
                    HandleRosBridgeMessageOperation.ServiceResponse -> handleService(message)
                    null -> Unit
                }
            }
        }
    }

    // endregion

    companion object {
        /**
         * rosbridge の送信用 JSON では `op` 等が必須。kotlinx.serialization は既定で
         * プロパティのデフォルト値をエンコードしないため [encodeDefaults] を有効にする。
         * [explicitNulls] を false にし、`id` / `throttle_rate` が null のときキー自体を送らない。
         */
        private val json = Json {
            ignoreUnknownKeys = true
            encodeDefaults = true
            explicitNulls = false
        }
    }
}
