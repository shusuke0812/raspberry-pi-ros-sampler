package com.shusuke.raspberry_pi_android_client.di

import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.RosBridgeClient
import com.shusuke.raspberry_pi_android_client.data.infrastructure.websocket.WebSocketClient
import org.koin.core.module.dsl.singleOf
import org.koin.dsl.module

/**
 * Data 層 Infrastructure の DI モジュール。
 *
 * - [WebSocketClient]: OkHttp ベースの WebSocket クライアント
 * - [RosBridgeClient]: ROS Bridge プロトコル対応クライアント
 */
val infrastructureModule = module {
    singleOf(::WebSocketClient)
    singleOf(::RosBridgeClient)
}
