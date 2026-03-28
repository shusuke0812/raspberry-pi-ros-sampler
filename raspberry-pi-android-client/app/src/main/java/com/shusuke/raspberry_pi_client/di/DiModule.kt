package com.shusuke.raspberry_pi_client.di

import android.app.Application
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

/**
 * Koin DI のモジュール定義。
 */
object DiModule {

    /**
     * 全モジュールを登録して Koin を初期化する。
     * Application の onCreate で呼び出す。
     */
    fun init(application: Application) {
        startKoin {
            androidContext(application)
            modules(infrastructureModule, repositoryModule, viewModelModule)
        }
    }
}
