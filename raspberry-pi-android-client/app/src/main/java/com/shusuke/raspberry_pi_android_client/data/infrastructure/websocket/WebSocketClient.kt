package com.shusuke.raspberry_pi_android_client.data.infrastructure.websocket

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import java.util.concurrent.TimeUnit

/**
 * OkHttp を用いた WebSocket クライアント
 *
 * 接続状態を [connectionState] で、テキスト/バイナリメッセージを [textMessages] / [binaryMessages] で公開する
 */
class WebSocketClient(
    private val okHttpClient: OkHttpClient = OkHttpClient.Builder()
        .pingInterval(20, TimeUnit.SECONDS)
        .build(),
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private val _connectionState = MutableStateFlow<WebSocketConnectionState>(WebSocketConnectionState.Ready)
    private val _textMessages = MutableSharedFlow<String>()
    private val _binaryMessages = MutableSharedFlow<ByteArray>()

    val connectionState: StateFlow<WebSocketConnectionState> = _connectionState.asStateFlow()
    val textMessages: SharedFlow<String> = _textMessages.asSharedFlow()
    val binaryMessages: SharedFlow<ByteArray> = _binaryMessages.asSharedFlow()

    @Volatile
    private var webSocket: WebSocket? = null

    private var connectionTimeoutJob: Job? = null

    private val connectionTimeoutMs = 10_000L

    /**
     * WebSocket に接続する。
     *
     * @param webSocketUrl 接続先の URL（[WebSocketUrl.rosBridge] または [WebSocketUrl.foxgloveBridge]）
     */
    fun connect(webSocketUrl: WebSocketUrl) {
        disconnect()

        _connectionState.value = WebSocketConnectionState.Connecting

        val request = webSocketUrl.toRequest().build()
        webSocket = okHttpClient.newWebSocket(request, createListener())

        startConnectionTimeout()
    }

    /** WebSocket を切断する。 */
    fun disconnect() {
        connectionTimeoutJob?.cancel()
        connectionTimeoutJob = null

        webSocket?.close(NORMAL_CLOSURE_CODE, null)
        webSocket = null

        if (_connectionState.value is WebSocketConnectionState.Connecting) {
            _connectionState.value = WebSocketConnectionState.Ready
        }
    }

    /**
     * テキストメッセージを送信する。
     *
     * @throws IllegalStateException 未接続の場合
     */
    fun send(text: String): Boolean {
        val ws = webSocket ?: return false
        return ws.send(text)
    }

    /**
     * バイナリメッセージを送信する。
     *
     * @throws IllegalStateException 未接続の場合
     */
    fun send(data: ByteArray): Boolean {
        val ws = webSocket ?: return false
        return ws.send(okio.ByteString.of(*data))
    }

    private fun createListener(): WebSocketListener =
        object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                connectionTimeoutJob?.cancel()
                connectionTimeoutJob = null
                _connectionState.value = WebSocketConnectionState.Connected
            }

            override fun onMessage(webSocket: WebSocket, text: String) {
                scope.launch {
                    _textMessages.emit(text)
                }
            }

            override fun onMessage(webSocket: WebSocket, bytes: okio.ByteString) {
                scope.launch {
                    _binaryMessages.emit(bytes.toByteArray())
                }
            }

            override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
                // do nothing
            }

            override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                val reasonOrNull = reason.ifEmpty { null }
                _connectionState.value = WebSocketConnectionState.Disconnected(
                    closeCode = code,
                    reason = reasonOrNull,
                )
                webSocket.close(NORMAL_CLOSURE_CODE, null)
            }

            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                connectionTimeoutJob?.cancel()
                connectionTimeoutJob = null

                when (_connectionState.value) {
                    is WebSocketConnectionState.Connecting -> {
                        _connectionState.value = WebSocketConnectionState.Disconnected(
                            closeCode = -1,
                            reason = t.message ?: t.toString(),
                        )
                        _connectionState.value = WebSocketConnectionState.Ready
                    }
                    else -> {
                        _connectionState.value = WebSocketConnectionState.Disconnected(
                            closeCode = -1,
                            reason = t.message ?: t.toString(),
                        )
                    }
                }
                webSocket.close(NORMAL_CLOSURE_CODE, null)
            }
        }

    private fun startConnectionTimeout() {
        connectionTimeoutJob?.cancel()
        connectionTimeoutJob = scope.launch {
            delay(connectionTimeoutMs)
            if (_connectionState.value is WebSocketConnectionState.Connecting) {
                webSocket?.close(NORMAL_CLOSURE_CODE, null)
                webSocket = null
                _connectionState.value = WebSocketConnectionState.ConnectingTimeout
                _connectionState.value = WebSocketConnectionState.Ready
            }
            connectionTimeoutJob = null
        }
    }

    companion object {
        private const val NORMAL_CLOSURE_CODE = 1000
    }
}
