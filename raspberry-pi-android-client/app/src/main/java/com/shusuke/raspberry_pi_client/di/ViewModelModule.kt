package com.shusuke.raspberry_pi_client.di

import com.shusuke.raspberry_pi_client.presentation.screen.connection.ConnectionViewModel
import com.shusuke.raspberry_pi_client.presentation.screen.service.CallServiceViewModel
import com.shusuke.raspberry_pi_client.presentation.screen.topic.TopicMonitorViewModel
import org.koin.core.module.dsl.viewModelOf
import org.koin.dsl.module

/** Presentation 層 ViewModel の DI モジュール。 */
val viewModelModule = module {
    viewModelOf(::ConnectionViewModel)
    viewModelOf(::TopicMonitorViewModel)
    viewModelOf(::CallServiceViewModel)
}
