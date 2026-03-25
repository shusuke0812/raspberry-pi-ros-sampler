package com.shusuke.raspberry_pi_android_client.presentation.screen.connection

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.shusuke.raspberry_pi_android_client.data.infrastructure.websocket.WebSocketConnectionState
import com.shusuke.raspberry_pi_android_client.data.repository.connection.ConnectionMode
import com.shusuke.raspberry_pi_android_client.data.repository.connection.RosConnectionRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/**
 * 接続画面用 ViewModel（iOS [ConnectionViewModel] に相当）。
 */
class ConnectionViewModel(
    private val rosConnectionRepository: RosConnectionRepository,
) : ViewModel() {

    private val _connectionStatus =
        MutableStateFlow<WebSocketConnectionState>(WebSocketConnectionState.Ready)
    val connectionStatus: StateFlow<WebSocketConnectionState> = _connectionStatus.asStateFlow()

    private val _ipAddress = MutableStateFlow("")
    val ipAddress: StateFlow<String> = _ipAddress.asStateFlow()

    private val _connectionMode = MutableStateFlow(ConnectionMode.ROS_BRIDGE)
    val connectionMode: StateFlow<ConnectionMode> = _connectionMode.asStateFlow()

    val isConnectButtonDisabled: StateFlow<Boolean> = combine(
        _ipAddress,
        _connectionStatus,
    ) { ip, status ->
        ip.trim().isBlank() ||
            status is WebSocketConnectionState.Connecting ||
            status is WebSocketConnectionState.Connected
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = true,
    )

    init {
        viewModelScope.launch {
            rosConnectionRepository.observeConnectionState().collect { state ->
                _connectionStatus.value = state
            }
        }
    }

    fun setIpAddress(value: String) {
        _ipAddress.value = value
    }

    fun setConnectionMode(mode: ConnectionMode) {
        _connectionMode.value = mode
    }

    fun connect() {
        rosConnectionRepository.connect(
            ipAddress = _ipAddress.value.trim(),
            connectionMode = _connectionMode.value,
        )
    }

    fun disconnect() {
        rosConnectionRepository.disconnect()
    }
}
