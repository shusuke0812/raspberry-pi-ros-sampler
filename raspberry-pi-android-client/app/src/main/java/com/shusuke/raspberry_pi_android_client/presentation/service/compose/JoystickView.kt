package com.shusuke.raspberry_pi_android_client.presentation.service.compose

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * ドラッグ可能な円形ジョイスティック（iOS [JoystickView] に相当）。
 *
 * @param screenWidthPx レイアウト幅（[KnobPosition] のスケール計算用。通常は画面幅の px）
 */
@Composable
fun JoystickView(
    knobPosition: KnobPosition,
    onKnobPositionChange: (KnobPosition) -> Unit,
    screenWidthPx: Float,
    modifier: Modifier = Modifier,
    isShowDebugView: Boolean = false,
) {
    val density = LocalDensity.current
    val parentPx = KnobPosition.parentCircleWidth(screenWidthPx)
    val chevronPx = KnobPosition.chevronWidth(screenWidthPx)
    val boxPx = maxOf(chevronPx, parentPx)

    val parentSizeDp = with(density) { parentPx.toDp() }
    val boxSizeDp = with(density) { boxPx.toDp() }

    var dragAccum by remember { mutableStateOf(Offset.Zero) }

    val up = knobPosition.height > 10f
    val down = knobPosition.height < -10f
    val left = knobPosition.width < -10f
    val right = knobPosition.width > 10f

    val chevronActive = Color.Black
    val chevronInactive = Color.Black.copy(alpha = 0.2f)

    Box(
        modifier = modifier.size(boxSizeDp),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier
                .size(parentSizeDp)
                .shadow(
                    elevation = 10.dp,
                    shape = CircleShape,
                    ambientColor = Color.White.copy(alpha = 0.1f),
                    spotColor = Color.Black.copy(alpha = 0.5f),
                )
                .background(Color.Gray.copy(alpha = 0.1f), CircleShape)
                .pointerInput(screenWidthPx) {
                    detectDragGestures(
                        onDragStart = { dragAccum = Offset.Zero },
                        onDrag = { _, dragAmount ->
                            dragAccum += dragAmount
                            onKnobPositionChange(
                                KnobPosition(screenWidthPx = screenWidthPx)
                                    .withDragTranslation(dragAccum.x, dragAccum.y),
                            )
                        },
                        onDragCancel = {
                            dragAccum = Offset.Zero
                            onKnobPositionChange(KnobPosition(screenWidthPx = screenWidthPx))
                        },
                        onDragEnd = {
                            dragAccum = Offset.Zero
                            onKnobPositionChange(KnobPosition(screenWidthPx = screenWidthPx))
                        },
                    )
                },
            contentAlignment = Alignment.Center,
        ) {
            ShadowCircle(
                knobPosition = knobPosition,
                screenWidthPx = screenWidthPx,
                parentPx = parentPx,
            )
            KnobCircle(
                knobPosition = knobPosition,
                screenWidthPx = screenWidthPx,
                parentPx = parentPx,
            )
        }

        Column(
            modifier = Modifier
                .height(with(density) { chevronPx.toDp() })
                .align(Alignment.Center),
        ) {
            Text(
                text = "▲",
                fontSize = 35.sp,
                color = if (up) chevronActive else chevronInactive,
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "▼",
                fontSize = 35.sp,
                color = if (down) chevronActive else chevronInactive,
            )
        }

        Row(
            modifier = Modifier
                .width(with(density) { chevronPx.toDp() })
                .align(Alignment.Center),
        ) {
            Text(
                text = "◀",
                fontSize = 35.sp,
                color = if (left) chevronActive else chevronInactive,
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "▶",
                fontSize = 35.sp,
                color = if (right) chevronActive else chevronInactive,
            )
        }

        if (isShowDebugView) {
            JoystickDebugOverlay(
                knobPosition = knobPosition,
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }
    }
}

@Composable
private fun BoxScope.ShadowCircle(
    knobPosition: KnobPosition,
    screenWidthPx: Float,
    parentPx: Float,
) {
    val density = LocalDensity.current
    val shadowPx = KnobPosition.shadowCircleWidth(screenWidthPx)
    val shadowDp = with(density) { shadowPx.toDp() }
    val brush = Brush.radialGradient(
        colors = listOf(
            Color.Gray.copy(alpha = 0.1f),
            Color.Gray.copy(alpha = 0.2f),
            Color.Gray.copy(alpha = 0.3f),
            Color.Black,
        ),
        center = Offset.Zero,
        radius = parentPx * 0.8f,
    )
    Box(
        modifier = Modifier
            .offset(
                x = with(density) { (knobPosition.width * 0.6f).toDp() },
                y = with(density) { (-knobPosition.height * 0.6f).toDp() },
            )
            .size(shadowDp)
            .background(brush, CircleShape),
    )
}

@Composable
private fun BoxScope.KnobCircle(
    knobPosition: KnobPosition,
    screenWidthPx: Float,
    parentPx: Float,
) {
    val density = LocalDensity.current
    val knobPx = KnobPosition.knobCircleWidth(screenWidthPx)
    val knobDp = with(density) { knobPx.toDp() }
    val brush = Brush.radialGradient(
        colors = listOf(
            Color(0xFFE53935),
            Color(0xFFE53935).copy(alpha = 0.5f),
            Color(0xFFE53935).copy(alpha = 0.7f),
            Color.Black,
        ),
        center = Offset.Zero,
        radius = parentPx * 0.8f,
    )
    Box(
        modifier = Modifier
            .offset(
                x = with(density) { knobPosition.width.toDp() },
                y = with(density) { (-knobPosition.height).toDp() },
            )
            .size(knobDp)
            .background(brush, CircleShape),
    )
}

@Composable
private fun JoystickDebugOverlay(
    knobPosition: KnobPosition,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .background(Color.Black.copy(alpha = 0.7f), MaterialTheme.shapes.medium)
            .padding(8.dp),
    ) {
        Text(
            text = "X: ${knobPosition.x}, Y: ${knobPosition.y}",
            color = Color.White,
            fontSize = 20.sp,
        )
        Text(
            text = "Theta: ${knobPosition.theta}°",
            color = Color.White,
            fontSize = 20.sp,
        )
    }
}
