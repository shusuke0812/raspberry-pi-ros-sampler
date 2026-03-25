package com.shusuke.raspberry_pi_android_client.presentation.connection.compose

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.shusuke.raspberry_pi_android_client.R
import com.shusuke.raspberry_pi_android_client.data.infrastructure.websocket.WebSocketConnectionState
import com.shusuke.raspberry_pi_android_client.data.repository.connection.ConnectionMode
import com.shusuke.raspberry_pi_android_client.presentation.connection.ConnectionViewModel

/**
 * 接続画面（iOS [ConnectionScreen] に相当）。
 */
@Composable
fun ConnectionScreen(
    viewModel: ConnectionViewModel,
    modifier: Modifier = Modifier,
) {
    val ipAddress by viewModel.ipAddress.collectAsStateWithLifecycle()
    val connectionMode by viewModel.connectionMode.collectAsStateWithLifecycle()
    val connectionStatus by viewModel.connectionStatus.collectAsStateWithLifecycle()
    val isConnectButtonDisabled by viewModel.isConnectButtonDisabled.collectAsStateWithLifecycle()

    val focusManager = LocalFocusManager.current
    val configuration = LocalConfiguration.current
    val screenWidthDp = configuration.screenWidthDp.dp
    val fieldMaxWidth = screenWidthDp * 0.7f
    val buttonMaxWidth = screenWidthDp * 0.65f

    val modeSegmentEnabled =
        connectionStatus !is WebSocketConnectionState.Connected

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
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            SingleChoiceSegmentedButtonRow(
                modifier = Modifier.widthIn(max = fieldMaxWidth),
            ) {
                ConnectionMode.entries.forEachIndexed { index, mode ->
                    SegmentedButton(
                        selected = connectionMode == mode,
                        onClick = { viewModel.setConnectionMode(mode) },
                        enabled = modeSegmentEnabled,
                        shape = SegmentedButtonDefaults.itemShape(
                            index = index,
                            count = ConnectionMode.entries.size,
                        ),
                    ) {
                        Text(
                            text = mode.displayName,
                            maxLines = 1,
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(30.dp))

            OutlinedTextField(
                value = ipAddress,
                onValueChange = viewModel::setIpAddress,
                modifier = Modifier.widthIn(max = fieldMaxWidth),
                label = { Text(stringResource(R.string.connection_ip_address_label)) },
                singleLine = true,
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Decimal,
                    imeAction = ImeAction.Done,
                ),
                keyboardActions = KeyboardActions(
                    onDone = { focusManager.clearFocus() },
                ),
            )

            Spacer(modifier = Modifier.height(30.dp))

            Button(
                onClick = {
                    focusManager.clearFocus()
                    viewModel.connect()
                },
                modifier = Modifier
                    .widthIn(max = buttonMaxWidth)
                    .fillMaxWidth(),
                enabled = !isConnectButtonDisabled,
            ) {
                if (connectionStatus is WebSocketConnectionState.Connecting) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.dp,
                    )
                } else {
                    Text(stringResource(R.string.connection_connect))
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            Button(
                onClick = viewModel::disconnect,
                modifier = Modifier
                    .widthIn(max = buttonMaxWidth)
                    .fillMaxWidth(),
                enabled = connectionStatus is WebSocketConnectionState.Connected,
            ) {
                Text(stringResource(R.string.connection_disconnect))
            }

            Spacer(modifier = Modifier.height(30.dp))

            Text(
                text = "${connectionMode.displayName}: ${connectionStatus.description}",
                style = MaterialTheme.typography.titleMedium,
                textAlign = TextAlign.Center,
            )
        }
    }
}
