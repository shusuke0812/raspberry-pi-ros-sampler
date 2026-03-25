package com.shusuke.raspberry_pi_client.presentation.screen.service.compose

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
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.shusuke.raspberry_pi_client.R
import com.shusuke.raspberry_pi_client.presentation.screen.service.CallServiceViewModel

/**
 * Turtlesim サービス呼び出し画面（iOS [CallServiceScreen] に相当）。
 */
@Composable
fun CallServiceScreen(
    viewModel: CallServiceViewModel,
    modifier: Modifier = Modifier,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val knobPosition by viewModel.knobPosition.collectAsStateWithLifecycle()

    val focusManager = LocalFocusManager.current
    val configuration = LocalConfiguration.current
    val density = LocalDensity.current
    val screenWidthPx = with(density) { configuration.screenWidthDp.dp.toPx() }

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
            Column(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                if (uiState.isShowProgress) {
                    CircularProgressIndicator(
                        modifier = Modifier.padding(16.dp),
                    )
                } else {
                    Text(
                        text = uiState.title,
                        style = MaterialTheme.typography.bodyLarge.copy(
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = TextAlign.Center,
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                    )
                }
                Spacer(modifier = Modifier.weight(1f))
                Box(contentAlignment = Alignment.Center) {
                    JoystickView(
                        knobPosition = knobPosition,
                        onKnobPositionChange = viewModel::changeKnobPosition,
                        screenWidthPx = screenWidthPx,
                    )
                    if (uiState.joystickOverlayOpacity > 0f) {
                        Box(
                            modifier = Modifier
                                .matchParentSize()
                                .background(Color.White.copy(alpha = uiState.joystickOverlayOpacity))
                                .clickable(
                                    indication = null,
                                    interactionSource = remember { MutableInteractionSource() },
                                ) { },
                        )
                    }
                }
                Spacer(modifier = Modifier.weight(1f))
            }
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Button(
                    onClick = { viewModel.spawnTurtle() },
                    enabled = !uiState.isSpawnDisabled,
                    modifier = Modifier.weight(1f),
                ) {
                    Text(text = stringResource(R.string.service_spawn))
                }
                Button(
                    onClick = { viewModel.reset() },
                    enabled = !uiState.isResetDisabled,
                    modifier = Modifier.weight(1f),
                ) {
                    Text(text = stringResource(R.string.service_reset))
                }
            }
        }
    }
}
