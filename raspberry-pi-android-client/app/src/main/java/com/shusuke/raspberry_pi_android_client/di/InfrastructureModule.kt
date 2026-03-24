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
 *
 * [WebSocketClient] はコンストラクタに [OkHttpClient] のデフォルト引数がある。
 * [singleOf]（リフレクション）では Koin が [OkHttpClient] をコンテナから解決しようとして失敗するため、
 * Kotlin のデフォルト引数を使うファクトリで登録する。
 */
val infrastructureModule = module {
    single { WebSocketClient() }
    singleOf(::RosBridgeClient)
    singleOf(::FoxgloveBridgeClient)
}
