package com.shusuke.raspberry_pi_client.presentation.screen.service

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceError
import com.shusuke.raspberry_pi_client.data.repository.turtlesim.TurtlesimRepository
import com.shusuke.raspberry_pi_client.presentation.screen.service.compose.KnobPosition
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

/**
 * Turtlesim サービス画面用 ViewModel（iOS [CallServiceViewModel] に相当）。
 */
class CallServiceViewModel(
    private val turtlesimRepository: TurtlesimRepository,
) : ViewModel() {

    sealed class UiState {
        data object Standby : UiState()

        data object Loading : UiState()

        data class Success(val message: String) : UiState()

        data class Failure(val error: RosServiceError) : UiState()

        val title: String
            get() = when (this) {
                is Standby -> "Standby"
                is Loading -> ""
                is Success -> "Moving...\n$message"
                is Failure -> error.message ?: ""
            }

        val joystickDisabled: Boolean
            get() = when (this) {
                is Standby, is Loading, is Failure -> true
                is Success -> false
            }

        val joystickOverlayOpacity: Float
            get() = when (this) {
                is Standby, is Loading, is Failure -> 0.6f
                is Success -> 0f
            }

        val isShowProgress: Boolean
            get() = this is Loading

        val isSpawnDisabled: Boolean
            get() = when (this) {
                is Standby, is Failure -> false
                is Loading, is Success -> true
            }

        val isResetDisabled: Boolean
            get() = when (this) {
                is Standby, is Failure -> true
                is Loading, is Success -> false
            }
    }

    private val _uiState = MutableStateFlow<UiState>(UiState.Standby)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    private val _knobPosition = MutableStateFlow(KnobPosition())
    val knobPosition: StateFlow<KnobPosition> = _knobPosition.asStateFlow()

    private var moveJob: Job? = null

    fun changeKnobPosition(position: KnobPosition) {
        _knobPosition.value = position
    }

    fun spawnTurtle() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            val result = turtlesimRepository.spawnTurtle(x = 2f, y = 2f, theta = 0.2f)
            result.fold(
                onSuccess = {
                    _uiState.value = UiState.Success("")
                    startMoveTurtle()
                },
                onFailure = { e ->
                    val err = e as? RosServiceError
                        ?: RosServiceError.FailedReceiveMessage(e)
                    _uiState.value = UiState.Failure(err)
                },
            )
        }
    }

    fun reset() {
        turtlesimRepository.reset()
    }

    private fun startMoveTurtle() {
        stopMoveTurtle()
        moveJob = viewModelScope.launch(Dispatchers.Default) {
            while (isActive) {
                delay(200)
                val k = _knobPosition.value
                turtlesimRepository.moveTurtle(x = k.y, y = k.x, radian = k.radian)
            }
        }
    }

    private fun stopMoveTurtle() {
        moveJob?.cancel()
        moveJob = null
    }

    override fun onCleared() {
        super.onCleared()
        stopMoveTurtle()
    }
}
