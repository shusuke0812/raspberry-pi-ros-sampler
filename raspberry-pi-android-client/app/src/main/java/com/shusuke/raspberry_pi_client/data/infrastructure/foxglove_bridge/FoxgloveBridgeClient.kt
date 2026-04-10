package com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge

import android.util.Log
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.binary.FoxgloveBinaryMessageEncoder
import com.shusuke.raspberry_pi_client.data.infrastructure.util.BinaryLogHelpers
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.binary.FoxgloveBinaryMessageParser
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.binary.FoxgloveServerBinaryMessage
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common.FoxgloveJsonMessageParser
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common.FoxgloveWireEncoding
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.common.FoxgloveServerJsonMessage
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.server.FoxgloveServerInfo
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic.FoxgloveClientAdvertise
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic.FoxgloveClientAdvertiseChannel
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic.FoxgloveSubscribe
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic.FoxgloveSubscribeSubscription
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove_bridge.topic.FoxgloveUnsubscribe
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosCallService
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceError
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceResponse
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicError
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicSubscribe
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message.Int8Message
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message.StringMessage
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketClient
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketConnectionState
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketUrl
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlin.Result
import java.util.concurrent.atomic.AtomicInteger

/**
 * Foxglove Bridge 用クライアント
 *
 * ポート 8765、サブプロトコル `foxglove.sdk.v1` で接続する。
 * serverInfo, advertise, advertiseServices の受信とマップ保持を行い、
 * RosBridge と同等の publish / subscribe / callService を提供する。
 *
 * Ref: https://docs.foxglove.dev/sdk
 */
class FoxgloveBridgeClient(
    private val webSocketClient: WebSocketClient,
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val json = FoxgloveJsonMessageParser.jsonInstance

    private val mapMutex = Mutex()
    @Volatile
    private var serverInfo: FoxgloveServerInfo? = null
    private val topicToChannelIdMap = mutableMapOf<String, UInt>()
    private val topicToEncodingMap = mutableMapOf<String, String>()
    private val channelIdToTopicMap = mutableMapOf<UInt, String>()
    private val serviceNameToIdMap = mutableMapOf<String, UInt>()
    private val serviceIdToNameMap = mutableMapOf<UInt, String>()
    private val serviceNameToRequestEncodingMap = mutableMapOf<String, String>()

    private val clientPublishMutex = Mutex()
    private val clientPublishTopicToChannelId = mutableMapOf<String, UInt>()
    private val nextClientChannelId = AtomicInteger(1)

    private val subscriptionMutex = Mutex()
    private val topicToSubscriptionInfo = mutableMapOf<String, FoxgloveSubscriptionInfo>()
    private val subscriptionIdToTopic = mutableMapOf<UInt, String>()
    private val nextSubscriptionId = AtomicInteger(1)

    private val serviceCallMutex = Mutex()
    private val callIdToHandler =
        mutableMapOf<UInt, (Result<Triple<ByteArray, String, FoxgloveWireEncoding>>) -> Unit>()
    private val nextCallId = AtomicInteger(1)

    init {
        observeReceivedMessage()
    }

    // region Connection

    /**
     * Foxglove Bridge に接続する。
     *
     * @param ipAddress 接続先 IP アドレス（例: "192.168.1.100"）
     */
    fun connect(ipAddress: String) {
        val url = WebSocketUrl.foxgloveBridge(ipAddress)
        webSocketClient.connect(url)
    }

    /** Foxglove Bridge を切断する。 */
    fun disconnect() {
        runBlocking {
            clearMaps()
            clearSubscriptions()
            clearServiceCallHandlers()
        }
        webSocketClient.disconnect()
        // text/binary の collect はキャンセルしない。キャンセルすると再接続後に
        // 受信ループが動かずメッセージが届かない。
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
     * serverInfo で clientPublish と json がサポートされている場合のみ動作する。
     *
     * @param topic op=publish の [RosTopicPublish]
     * @param schemaName ROS スキーマ名（例: "std_msgs/msg/String"）
     */
    internal fun <T> publish(
        topic: RosTopicPublish<T>,
        messageSerializer: KSerializer<T>,
        schemaName: String,
    ) {
        scope.launch {
            val supportsPublish = mapMutex.withLock {
                serverInfo?.supportsClientPublish == true && serverInfo?.supportsJsonEncoding == true
            }
            if (!supportsPublish) return@launch

            val (channelId, needsAdvertise) = clientPublishMutex.withLock {
                val existing = clientPublishTopicToChannelId[topic.topic]
                if (existing != null) {
                    Pair(existing, false)
                } else {
                    val id = nextClientChannelId.getAndIncrement().toUInt()
                    clientPublishTopicToChannelId[topic.topic] = id
                    Pair(id, true)
                }
            }

            val payloadBytes = runCatching {
                json.encodeToString(messageSerializer, topic.message).encodeToByteArray()
            }.getOrNull() ?: return@launch

            if (needsAdvertise) {
                sendClientAdvertise(topic.topic, channelId, schemaName)
            }
            val binaryData = FoxgloveBinaryMessageEncoder.encodeClientMessageData(channelId, payloadBytes)
            Log.d("test", "send(encodeClientMessageData): ${BinaryLogHelpers.toHexString(binaryData)}")
            webSocketClient.send(binaryData)
        }
    }

    private fun sendClientAdvertise(topic: String, channelId: UInt, schemaName: String) {
        val channel = FoxgloveClientAdvertiseChannel(
            id = channelId,
            topic = topic,
            encoding = FoxgloveWireEncoding.Json.wireName,
            schemaName = schemaName,
            schema = null,
            schemaEncoding = null,
        )
        val advertise = FoxgloveClientAdvertise(channels = listOf(channel))
        val jsonString = json.encodeToString(FoxgloveClientAdvertise.serializer(), advertise)
        webSocketClient.send(jsonString)
    }

    // endregion

    // region Subscribe

    /**
     * トピックの購読を開始する。
     *
     * すでに購読済みの場合は [RosTopicError.AlreadySubscribed] を即座にコールバックする。
     * トピックが advertise されていない場合は [RosTopicError.ChannelNotFound] をコールバックする。
     */
    internal fun <M> startSubscribe(
        topic: RosTopicSubscribe,
        messageSerializer: KSerializer<M>,
        onMessage: (Result<RosTopicPublish<M>>) -> Unit,
    ) {
        scope.launch {
            val channelId = mapMutex.withLock { topicToChannelIdMap[topic.topic] }
                ?: run {
                    onMessage(Result.failure(RosTopicError.ChannelNotFound))
                    return@launch
                }

            val alreadySubscribed = subscriptionMutex.withLock {
                topicToSubscriptionInfo.containsKey(topic.topic)
            }
            if (alreadySubscribed) {
                onMessage(Result.failure(RosTopicError.AlreadySubscribed))
                return@launch
            }

            val subscriptionId = nextSubscriptionId.getAndIncrement().toUInt()
            val encodingRaw = mapMutex.withLock { topicToEncodingMap[topic.topic] }
                ?: FoxgloveWireEncoding.Json.wireName
            val encoding = FoxgloveWireEncoding.parse(encodingRaw)

            val onPayload: (Result<ByteArray>) -> Unit = { result ->
                result.fold(
                    onSuccess = { payload ->
                        when (encoding) {
                            FoxgloveWireEncoding.Json -> {
                                runCatching {
                                    val msg = json.decodeFromString(messageSerializer, payload.decodeToString())
                                    RosTopicPublish(topic = topic.topic, message = msg)
                                }.fold(
                                    onSuccess = { decoded -> onMessage(Result.success(decoded)) },
                                    onFailure = { e -> onMessage(Result.failure(RosTopicError.FailedDecodeMessage(e))) },
                                )
                            }
                            FoxgloveWireEncoding.Cdr -> {
                                val publish = when (topic.messageType) {
                                    StringMessage.ROS_MESSAGE_TYPE ->
                                        StringMessage.decodeFromCdr(payload)
                                            ?.let { RosTopicPublish(topic = topic.topic, message = it) }
                                    Int8Message.ROS_MESSAGE_TYPE ->
                                        Int8Message.decodeFromCdr(payload)
                                            ?.let { RosTopicPublish(topic = topic.topic, message = it) }
                                    else -> null
                                }
                                if (publish != null) {
                                    @Suppress("UNCHECKED_CAST")
                                    val typed = publish as RosTopicPublish<M>
                                    onMessage(Result.success(typed))
                                } else {
                                    onMessage(
                                        Result.failure(
                                            RosTopicError.FailedDecodeMessage(
                                                Exception(
                                                    "CDR decode failed or unsupported message type: ${topic.messageType}",
                                                ),
                                            ),
                                        ),
                                    )
                                }
                            }
                            is FoxgloveWireEncoding.Unsupported -> {
                                onMessage(
                                    Result.failure(
                                        RosTopicError.FailedDecodeMessage(
                                            Exception(
                                                "Unsupported encoding for subscribe: ${encoding.raw}",
                                            ),
                                        ),
                                    ),
                                )
                            }
                        }
                    },
                    onFailure = { e -> onMessage(Result.failure(RosTopicError.FailedReceiveMessage(e))) },
                )
            }

            subscriptionMutex.withLock {
                topicToSubscriptionInfo[topic.topic] = FoxgloveSubscriptionInfo(
                    subscriptionId = subscriptionId,
                    onPayload = onPayload,
                )
                subscriptionIdToTopic[subscriptionId] = topic.topic
            }

            val subscribe = FoxgloveSubscribe(
                subscriptions = listOf(
                    FoxgloveSubscribeSubscription(id = subscriptionId, channelId = channelId),
                ),
            )
            val jsonString = json.encodeToString(FoxgloveSubscribe.serializer(), subscribe)
            webSocketClient.send(jsonString)
        }
    }

    /**
     * トピックの購読を終了する。
     */
    fun endSubscribe(topic: RosTopicSubscribe) {
        scope.launch {
            val (subscriptionId, _) = subscriptionMutex.withLock {
                val info = topicToSubscriptionInfo.remove(topic.topic)
                val subId = info?.subscriptionId
                if (subId != null) subscriptionIdToTopic.remove(subId)
                Pair(subId, info)
            } ?: return@launch

            if (subscriptionId != null) {
                val unsubscribe = FoxgloveUnsubscribe(subscriptionIds = listOf(subscriptionId))
                val jsonString = json.encodeToString(FoxgloveUnsubscribe.serializer(), unsubscribe)
                webSocketClient.send(jsonString)
            }
        }
    }

    // endregion

    // region Service

    /**
     * ROS サービスを呼び出す。
     *
     * すでに同じサービスを呼び出し中の場合は [RosServiceError.AlreadyCalling] を即座にコールバックする。
     */
    internal fun <A, R> callService(
        service: RosCallService<A>,
        argsSerializer: KSerializer<A>,
        responseSerializer: KSerializer<RosServiceResponse<R>>,
        onMessage: (Result<RosServiceResponse<R>>) -> Unit,
        cdrEncoder: ((A) -> ByteArray)? = null,
        cdrResponseDecoder: ((ByteArray) -> R)? = null,
    ) {
        scope.launch {
            val supportsServices = mapMutex.withLock { serverInfo?.supportsServices == true }
            if (!supportsServices) {
                onMessage(
                    Result.failure(
                        RosServiceError.FailedReceiveMessage(
                            Exception("Server does not support services"),
                        ),
                    ),
                )
                return@launch
            }

            val serviceId = mapMutex.withLock { serviceNameToIdMap[service.service] }
                ?: run {
                    onMessage(
                        Result.failure(
                            RosServiceError.FailedReceiveMessage(
                                Exception("Service '${service.service}' not found in advertiseServices"),
                            ),
                        ),
                    )
                    return@launch
                }

            val requestEncodingRaw = mapMutex.withLock {
                serviceNameToRequestEncodingMap[service.service]
            } ?: FoxgloveWireEncoding.Json.wireName
            val requestEncoding = FoxgloveWireEncoding.parse(requestEncodingRaw)

            val payloadBytes: ByteArray = when (requestEncoding) {
                FoxgloveWireEncoding.Json -> {
                    Log.d("test", "JSON !!!!")
                    runCatching {
                        service.args?.let { json.encodeToString(argsSerializer, it) } ?: "{}"
                    }.fold(
                        onSuccess = { it.encodeToByteArray() },
                        onFailure = {
                            onMessage(Result.failure(RosServiceError.FailedReceiveMessage(it)))
                            return@launch
                        },
                    )
                }
                FoxgloveWireEncoding.Cdr -> {
                    val args = service.args
                    Log.d("test", "CDR !!!!, encoder=$cdrEncoder, args=$args")
                    if (cdrEncoder == null || args == null) {
                        onMessage(
                            Result.failure(
                                RosServiceError.FailedReceiveMessage(
                                    Exception("CDR encoder not provided for service '${service.service}'"),
                                ),
                            ),
                        )
                        return@launch
                    }
                    runCatching { cdrEncoder(args) }.fold(
                        onSuccess = { it },
                        onFailure = {
                            onMessage(Result.failure(RosServiceError.FailedReceiveMessage(it)))
                            return@launch
                        },
                    )
                }
                is FoxgloveWireEncoding.Unsupported -> {
                    onMessage(
                        Result.failure(
                            RosServiceError.FailedReceiveMessage(
                                Exception("Unsupported encoding: ${requestEncoding.raw}"),
                            ),
                        ),
                    )
                    return@launch
                }
            }

            val callId = nextCallId.getAndIncrement().toUInt()
            serviceCallMutex.withLock {
                callIdToHandler[callId] = { result ->
                    result.fold(
                        onSuccess = { (payload, serviceName, responseEncoding) ->
                            when (responseEncoding) {
                                FoxgloveWireEncoding.Json -> {
                                    runCatching {
                                        val valuesJson = payload.decodeToString()
                                        val wrappedJson = buildJsonObject {
                                            put("op", "service_response")
                                            put("service", serviceName)
                                            put("result", true)
                                            put("values", json.parseToJsonElement(valuesJson))
                                        }
                                        json.decodeFromJsonElement(responseSerializer, wrappedJson)
                                    }.fold(
                                        onSuccess = { decoded -> onMessage(Result.success(decoded)) },
                                        onFailure = { e ->
                                            onMessage(Result.failure(RosServiceError.FailedDecodeMessage(e)))
                                        },
                                    )
                                }
                                FoxgloveWireEncoding.Cdr -> {
                                    val decoder = cdrResponseDecoder
                                    if (decoder == null) {
                                        onMessage(
                                            Result.failure(
                                                RosServiceError.FailedDecodeMessage(
                                                    Exception(
                                                        "CDR response decoder not provided for service '$serviceName'",
                                                    ),
                                                ),
                                            ),
                                        )
                                    } else {
                                        runCatching {
                                            val decodedValues = decoder(payload)
                                            RosServiceResponse(service = serviceName, values = decodedValues)
                                        }.fold(
                                            onSuccess = { decoded -> onMessage(Result.success(decoded)) },
                                            onFailure = { e ->
                                                onMessage(Result.failure(RosServiceError.FailedDecodeMessage(e)))
                                            },
                                        )
                                    }
                                }
                                is FoxgloveWireEncoding.Unsupported -> {
                                    onMessage(
                                        Result.failure(
                                            RosServiceError.FailedDecodeMessage(
                                                Exception(
                                                    "Unsupported encoding for service response: ${responseEncoding.raw}",
                                                ),
                                            ),
                                        ),
                                    )
                                }
                            }
                        },
                        onFailure = { e -> onMessage(Result.failure(RosServiceError.FailedReceiveMessage(e))) },
                    )
                }
            }

            val binaryData = FoxgloveBinaryMessageEncoder.encodeServiceCallRequest(
                serviceId = serviceId,
                callId = callId,
                encoding = requestEncoding.wireName,
                payload = payloadBytes,
            )
            Log.d("FoxgloveBridgeClient", "send(encodeServiceCallRequest): ${BinaryLogHelpers.toHexString(binaryData)}")
            webSocketClient.send(binaryData)
        }
    }

    // endregion

    // region Message handling

    private fun observeReceivedMessage() {
        scope.launch {
            webSocketClient.textMessages.collect { message ->
                handleJsonMessage(message)
            }
        }
        scope.launch {
            webSocketClient.binaryMessages.collect { data ->
                handleBinaryMessage(data)
            }
        }
    }

    private fun handleJsonMessage(jsonString: String) {
        val parsed = FoxgloveJsonMessageParser.parseServerMessage(jsonString) ?: return
        scope.launch {
            when (parsed) {
                is FoxgloveServerJsonMessage.ServerInfo -> {
                    mapMutex.withLock {
                        serverInfo = parsed.info
                    }
                }
                is FoxgloveServerJsonMessage.Advertise -> {
                    Log.d("test", "advertise parsed=$parsed")
                    mapMutex.withLock {
                        for ((topic, channelId) in parsed.advertise.topicToChannelIdMap()) {
                            topicToChannelIdMap[topic] = channelId
                            channelIdToTopicMap[channelId] = topic
                        }
                        for ((topic, enc) in parsed.advertise.topicToEncodingMap()) {
                            topicToEncodingMap[topic] = enc
                        }
                    }
                }
                is FoxgloveServerJsonMessage.Unadvertise -> {
                    mapMutex.withLock {
                        for (channelId in parsed.channelIds) {
                            channelIdToTopicMap.remove(channelId)?.let { topic ->
                                topicToChannelIdMap.remove(topic)
                                topicToEncodingMap.remove(topic)
                            }
                        }
                    }
                }
                is FoxgloveServerJsonMessage.AdvertiseServices -> {
                    Log.d("test", "advertise service parsed=$parsed")
                    mapMutex.withLock {
                        for ((name, id) in parsed.services.serviceNameToIdMap()) {
                            serviceNameToIdMap[name] = id
                            serviceIdToNameMap[id] = name
                        }
                        for ((name, enc) in parsed.services.serviceNameToRequestEncodingMap()) {
                            serviceNameToRequestEncodingMap[name] = enc
                        }
                    }
                }
                is FoxgloveServerJsonMessage.UnadvertiseServices -> {
                    mapMutex.withLock {
                        for (serviceId in parsed.serviceIds) {
                            serviceIdToNameMap.remove(serviceId)?.let { name ->
                                serviceNameToIdMap.remove(name)
                                serviceNameToRequestEncodingMap.remove(name)
                            }
                        }
                    }
                }
                is FoxgloveServerJsonMessage.ServiceCallFailure -> {
                    val handler = serviceCallMutex.withLock {
                        callIdToHandler.remove(parsed.callId)
                    }
                    handler?.invoke(
                        Result.failure(
                            RosServiceError.FailedReceiveMessage(
                                Exception(parsed.message),
                            ),
                        ),
                    )
                }
                is FoxgloveServerJsonMessage.Other -> Unit
            }
        }
    }

    private fun handleBinaryMessage(data: ByteArray) {
        val parsed = FoxgloveBinaryMessageParser.parseServerMessage(data)
        scope.launch {
            when (parsed) {
                is FoxgloveServerBinaryMessage.MessageData -> {
                    val topic = subscriptionMutex.withLock { subscriptionIdToTopic[parsed.subscriptionId] }
                    val info = subscriptionMutex.withLock { topic?.let { topicToSubscriptionInfo[it] } }
                    info?.onPayload?.invoke(Result.success(parsed.payload))
                }
                is FoxgloveServerBinaryMessage.ServiceCallResponse -> {
                    val handler = serviceCallMutex.withLock {
                        callIdToHandler.remove(parsed.callId)
                    }
                    val serviceName = mapMutex.withLock {
                        serviceIdToNameMap[parsed.serviceId] ?: ""
                    }
                    val responseEncoding = FoxgloveWireEncoding.parse(parsed.encoding)
                    handler?.invoke(
                        Result.success(
                            Triple(parsed.payload, serviceName, responseEncoding),
                        ),
                    )
                }
                is FoxgloveServerBinaryMessage.Unknown -> Unit
            }
        }
    }

    // endregion

    // region Cleanup

    private suspend fun clearMaps() {
        mapMutex.withLock {
            serverInfo = null
            topicToChannelIdMap.clear()
            topicToEncodingMap.clear()
            channelIdToTopicMap.clear()
            serviceNameToIdMap.clear()
            serviceIdToNameMap.clear()
            serviceNameToRequestEncodingMap.clear()
        }
        clientPublishMutex.withLock {
            clientPublishTopicToChannelId.clear()
            nextClientChannelId.set(1)
        }
    }

    private suspend fun clearSubscriptions() {
        subscriptionMutex.withLock {
            topicToSubscriptionInfo.clear()
            subscriptionIdToTopic.clear()
            nextSubscriptionId.set(1)
        }
    }

    private suspend fun clearServiceCallHandlers() {
        val handlers = serviceCallMutex.withLock {
            val list = callIdToHandler.values.toList()
            callIdToHandler.clear()
            nextCallId.set(1)
            list
        }
        val error = RosServiceError.FailedReceiveMessage(Exception("Connection closed"))
        handlers.forEach { it.invoke(Result.failure(error)) }
    }

    // endregion

    private data class FoxgloveSubscriptionInfo(
        val subscriptionId: UInt,
        val onPayload: (Result<ByteArray>) -> Unit,
    )
}
