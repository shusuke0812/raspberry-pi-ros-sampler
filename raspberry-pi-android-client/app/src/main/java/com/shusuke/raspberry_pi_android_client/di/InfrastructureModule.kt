package com.shusuke.raspberry_pi_android_client.di

import com.shusuke.raspberry_pi_android_client.data.infrastructure.foxglove.FoxgloveBridgeClient
import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.RosBridgeClient
import com.shusuke.raspberry_pi_android_client.data.infrastructure.websocket.WebSocketClient
import org.koin.core.module.dsl.singleOf
import org.koin.dsl.module

/**
 * Data 層 Infrastructure の DI モジュール。
 *
 * - [WebSocketClient]: OkHttp ベースの WebSocket クライアント
 * - [RosBridgeClient]: ROS Bridge プロトコル対応クライアント（ポート 9090）
 * - [FoxgloveBridgeClient]: Foxglove プロトコル対応クライアント（ポート 8765、サブプロトコル foxglove.sdk.v1）
 */
val infrastructureModule = module {
    singleOf(::WebSocketClient)
    singleOf(::RosBridgeClient)
    singleOf(::FoxgloveBridgeClient)
}
