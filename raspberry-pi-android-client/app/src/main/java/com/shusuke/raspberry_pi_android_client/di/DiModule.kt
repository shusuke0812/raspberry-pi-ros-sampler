package com.shusuke.raspberry_pi_android_client.di

import org.koin.core.context.startKoin

/**
 * Koin DI のモジュール定義。
 */
object DiModule {

    /**
     * 全モジュールを登録して Koin を初期化する。
     * Application の onCreate で呼び出す。
     */
    fun init() {
        startKoin {
            modules(infrastructureModule, repositoryModule)
        }
    }
}
