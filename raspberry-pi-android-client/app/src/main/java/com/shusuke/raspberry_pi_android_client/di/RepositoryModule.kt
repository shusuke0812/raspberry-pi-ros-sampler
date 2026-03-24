package com.shusuke.raspberry_pi_android_client.di

import com.shusuke.raspberry_pi_android_client.data.repository.connection.RosConnectionRepository
import com.shusuke.raspberry_pi_android_client.data.repository.hello.HelloTopicRepository
import com.shusuke.raspberry_pi_android_client.data.repository.turtlesim.TurtlesimRepository
import org.koin.core.module.dsl.singleOf
import org.koin.dsl.module

/**
 * Data 層 Repository の DI モジュール。
 *
 * - [RosConnectionRepository]: 接続管理（singleton）
 * - [HelloTopicRepository]: /hello, /hello_signal トピック購読
 * - [TurtlesimRepository]: turtlesim サービス・トピック操作
 */
val repositoryModule = module {
    singleOf(::RosConnectionRepository)
    singleOf(::HelloTopicRepository)
    singleOf(::TurtlesimRepository)
}
