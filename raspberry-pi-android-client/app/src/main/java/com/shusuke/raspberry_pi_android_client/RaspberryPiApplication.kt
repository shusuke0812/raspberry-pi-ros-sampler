package com.shusuke.raspberry_pi_android_client

import android.app.Application
import com.shusuke.raspberry_pi_android_client.di.DiModule

class RaspberryPiApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        DiModule.init(this)
    }
}
