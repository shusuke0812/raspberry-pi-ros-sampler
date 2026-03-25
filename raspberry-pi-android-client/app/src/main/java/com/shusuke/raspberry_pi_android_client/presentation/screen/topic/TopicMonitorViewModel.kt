package com.shusuke.raspberry_pi_android_client.presentation.screen.topic

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.topic.RosTopicError
import com.shusuke.raspberry_pi_android_client.data.repository.hello.HelloTopicRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * トピック監視画面用 ViewModel（iOS [TopicMonitorScreenViewModel] に相当）。
 */
class TopicMonitorViewModel(
    private val helloTopicRepository: HelloTopicRepository,
) : ViewModel() {

    sealed class UiState {
        data object Standby : UiState()

        data object Loading : UiState()

        data class Success(val messages: List<String>) : UiState()

        data class Failure(val error: RosTopicError) : UiState()

        val title: String
            get() = when (this) {
                is Standby -> "メッセージはありません"
                is Loading -> ""
                is Success -> ""
                is Failure -> error.message ?: ""
            }
    }

    private val _uiState = MutableStateFlow<UiState>(UiState.Standby)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    private val _isErrorPresented = MutableStateFlow(false)
    val isErrorPresented: StateFlow<Boolean> = _isErrorPresented.asStateFlow()

    private val messages = mutableListOf<String>()
    private var helloJob: Job? = null
    private var helloSignalJob: Job? = null

    fun hideErrorAlert() {
        _isErrorPresented.value = false
        if (messages.isEmpty()) {
            _uiState.value = UiState.Standby
        }
    }

    fun subscribeHelloMessage() {
        helloJob?.cancel()
        _uiState.value = UiState.Loading
        helloJob = viewModelScope.launch {
            helloTopicRepository.subscribeHello().collect { result ->
                withContext(Dispatchers.Main.immediate) {
                    result.fold(
                        onSuccess = { hello ->
                            messages.add(0, "${messages.size}.${hello.message.data}")
                            _uiState.value = UiState.Success(messages.toList())
                        },
                        onFailure = { err ->
                            _uiState.value = UiState.Failure(err.toRosTopicError())
                            _isErrorPresented.value = true
                        },
                    )
                }
            }
        }
    }

    fun unsubscribeHelloMessage() {
        helloJob?.cancel()
        helloJob = null
        messages.clear()
        helloTopicRepository.unsubscribeHello()
        _uiState.value = UiState.Standby
    }

    fun subscribeHelloSignal() {
        helloSignalJob?.cancel()
        _uiState.value = UiState.Loading
        helloSignalJob = viewModelScope.launch {
            helloTopicRepository.subscribeHelloSignal().collect { result ->
                withContext(Dispatchers.Main.immediate) {
                    result.fold(
                        onSuccess = { signal ->
                            messages.add(0, "${messages.size}.${signal.message.data}")
                            _uiState.value = UiState.Success(messages.toList())
                        },
                        onFailure = { err ->
                            _uiState.value = UiState.Failure(err.toRosTopicError())
                            _isErrorPresented.value = true
                        },
                    )
                }
            }
        }
    }

    fun unsubscribeHelloSignal() {
        helloSignalJob?.cancel()
        helloSignalJob = null
        messages.clear()
        helloTopicRepository.unsubscribeHelloSignal()
        _uiState.value = UiState.Standby
    }

    private fun Throwable.toRosTopicError(): RosTopicError =
        this as? RosTopicError ?: RosTopicError.FailedReceiveMessage(this)
}
