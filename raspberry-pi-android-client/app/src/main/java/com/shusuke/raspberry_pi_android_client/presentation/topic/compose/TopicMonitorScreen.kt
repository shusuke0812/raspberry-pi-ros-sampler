package com.shusuke.raspberry_pi_android_client.presentation.topic.compose

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.shusuke.raspberry_pi_android_client.R
import com.shusuke.raspberry_pi_android_client.presentation.topic.TopicMonitorViewModel

/**
 * トピック監視画面（iOS [TopicMonitorScreen] に相当）。
 */
@Composable
fun TopicMonitorScreen(
    viewModel: TopicMonitorViewModel,
    modifier: Modifier = Modifier,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val isErrorPresented by viewModel.isErrorPresented.collectAsStateWithLifecycle()

    val focusManager = LocalFocusManager.current

    Box(
        modifier = modifier
            .fillMaxSize()
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() },
            ) { focusManager.clearFocus() },
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
            ) {
                when (val state = uiState) {
                    is TopicMonitorViewModel.UiState.Standby -> {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = state.title,
                                style = MaterialTheme.typography.bodyLarge.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    textAlign = TextAlign.Center,
                                ),
                            )
                        }
                    }

                    is TopicMonitorViewModel.UiState.Loading -> {
                        Box(
                            modifier = Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center,
                        ) {
                            CircularProgressIndicator()
                        }
                    }

                    is TopicMonitorViewModel.UiState.Success -> {
                        LazyColumn(
                            modifier = Modifier.fillMaxSize(),
                            verticalArrangement = Arrangement.spacedBy(10.dp),
                        ) {
                            itemsIndexed(
                                items = state.messages,
                                key = { index, line -> "$index:$line" },
                            ) { _, line ->
                                Text(
                                    text = line,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .background(
                                            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                                            shape = RoundedCornerShape(8.dp),
                                        )
                                        .padding(horizontal = 16.dp, vertical = 8.dp),
                                    style = MaterialTheme.typography.bodyMedium,
                                )
                            }
                        }
                    }

                    is TopicMonitorViewModel.UiState.Failure -> {
                        Spacer(modifier = Modifier.fillMaxSize())
                    }
                }
            }

            TopicMonitorFooter(viewModel = viewModel)
        }

        if (isErrorPresented) {
            val failure = uiState as? TopicMonitorViewModel.UiState.Failure
            if (failure != null) {
                AlertDialog(
                    onDismissRequest = viewModel::hideErrorAlert,
                    confirmButton = {
                        TextButton(onClick = viewModel::hideErrorAlert) {
                            Text(text = stringResource(R.string.error_dialog_ok))
                        }
                    },
                    title = { Text(text = stringResource(R.string.error_dialog_title)) },
                    text = { Text(text = failure.error.message ?: "") },
                )
            }
        }
    }
}

@Composable
private fun TopicMonitorFooter(
    viewModel: TopicMonitorViewModel,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Button(
                onClick = viewModel::subscribeHelloMessage,
                modifier = Modifier.weight(1f),
            ) {
                Text(text = stringResource(R.string.topic_start_hello))
            }
            Button(
                onClick = viewModel::unsubscribeHelloMessage,
                modifier = Modifier.weight(1f),
            ) {
                Text(text = stringResource(R.string.topic_end_hello))
            }
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Button(
                onClick = viewModel::subscribeHelloSignal,
                modifier = Modifier.weight(1f),
            ) {
                Text(text = stringResource(R.string.topic_start_hello_signal))
            }
            Button(
                onClick = viewModel::unsubscribeHelloSignal,
                modifier = Modifier.weight(1f),
            ) {
                Text(text = stringResource(R.string.topic_end_hello_signal))
            }
        }
    }
}
