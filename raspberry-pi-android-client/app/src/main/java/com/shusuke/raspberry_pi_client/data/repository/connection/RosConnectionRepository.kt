package com.shusuke.raspberry_pi_client.data.repository.connection

import com.shusuke.raspberry_pi_client.data.infrastructure.MessageBridgeClient
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.FoxgloveBridgeClient
import com.shusuke.raspberry_pi_client.data.infrastructure.foxglove.FoxgloveMessageBridgeAdapter
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.RosBridgeClient
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.RosBridgeMessageBridgeAdapter
import com.shusuke.raspberry_pi_client.data.infrastructure.websocket.WebSocketConnectionState
import kotlinx.coroutines.flow.Flow

/**
 * ROS Bridge / Foxglove Bridge への接続を管理するリポジトリ。
 *
 * 接続モードに応じて [RosBridgeClient] または [FoxgloveBridgeClient] を選択し、
 * 両クライアントは同一の [WebSocketClient] を共有するため、
 * 同時に一方のみが接続される。
 */
class RosConnectionRepository(
    private val rosBridgeClient: RosBridgeClient,
    private val foxgloveBridgeClient: FoxgloveBridgeClient,
) {
    private val rosAdapter: MessageBridgeClient = RosBridgeMessageBridgeAdapter(rosBridgeClient)
    private val foxgloveAdapter: MessageBridgeClient = FoxgloveMessageBridgeAdapter(foxgloveBridgeClient)

    private var currentConnectionMode: ConnectionMode = ConnectionMode.ROS_BRIDGE

    /**
     * 現在の接続モードに応じたメッセージクライアント。
     */
    val activeMessageClient: MessageBridgeClient
        get() = when (currentConnectionMode) {
            ConnectionMode.ROS_BRIDGE -> rosAdapter
            ConnectionMode.FOXGLOVE_BRIDGE -> foxgloveAdapter
        }

    private val activeConnectionClient: RosBridgeConnectionClient
        get() = when (currentConnectionMode) {
            ConnectionMode.ROS_BRIDGE -> object : RosBridgeConnectionClient {
                override fun connect(ipAddress: String) = rosBridgeClient.connect(ipAddress)
                override fun disconnect() = rosBridgeClient.disconnect()
            }
            ConnectionMode.FOXGLOVE_BRIDGE -> object : RosBridgeConnectionClient {
                override fun connect(ipAddress: String) = foxgloveBridgeClient.connect(ipAddress)
                override fun disconnect() = foxgloveBridgeClient.disconnect()
            }
        }

    /**
     * 指定した IP アドレス・接続モードで接続する。
     */
    fun connect(ipAddress: String, connectionMode: ConnectionMode) {
        currentConnectionMode = connectionMode
        activeConnectionClient.connect(ipAddress)
    }

    /**
     * 現在の接続を切断する。
     */
    fun disconnect() {
        activeConnectionClient.disconnect()
    }

    /**
     * 接続状態の Flow。
     *
     * 両クライアントは同一 WebSocketClient を共有するため、
     * どちらかの observeConnectionState を返す。
     */
    fun observeConnectionState(): Flow<WebSocketConnectionState> =
        rosBridgeClient.observeConnectionState()

    private interface RosBridgeConnectionClient {
        fun connect(ipAddress: String)
        fun disconnect()
    }
}
