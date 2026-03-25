package com.shusuke.raspberry_pi_android_client.presentation.screen.service.compose

import kotlin.math.atan2
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min

/**
 * ジョイスティックノブ位置（iOS [KnobPosition] に相当）。
 *
 * @param screenWidthPx ジョイスティック配置画面の幅（px）。Compose 側から渡す。
 */
data class KnobPosition(
    val width: Float = 0f,
    val height: Float = 0f,
    val screenWidthPx: Float = 1080f,
) {
    companion object {
        private const val WF = 20f

        fun parentCircleWidth(screenWidthPx: Float): Float = screenWidthPx * 0.625f

        fun shadowCircleWidth(screenWidthPx: Float): Float = screenWidthPx * 0.375f

        fun knobCircleWidth(screenWidthPx: Float): Float = screenWidthPx * 0.25f

        fun chevronWidth(screenWidthPx: Float): Float = screenWidthPx * 0.875f
    }

    private val maxDistance: Float
        get() = parentCircleWidth(screenWidthPx) / 2f - knobCircleWidth(screenWidthPx) / 2f

    val x: Float
        get() {
            val normalized = (width / maxDistance) * WF
            val clamped = max(-10.0, min(10.0, normalized.toDouble()))
            return (floor(clamped * 100.0) / 100.0).toFloat()
        }

    val y: Float
        get() {
            val normalized = (height / maxDistance) * WF
            val clamped = max(-10.0, min(10.0, normalized.toDouble()))
            return (floor(clamped * 100.0) / 100.0).toFloat()
        }

    val theta: Float
        get() {
            val radians = atan2(x.toDouble(), y.toDouble())
            val degrees = radians * 180.0 / Math.PI
            return (if (degrees >= 0) degrees else degrees + 360.0).toFloat()
        }

    val radian: Float
        get() = -atan2(x.toDouble(), y.toDouble()).toFloat() * (WF / 2f)

    fun withDragTranslation(translationX: Float, translationY: Float): KnobPosition {
        val normalizedY = -translationY
        val distance = hypot(translationX.toDouble(), normalizedY.toDouble()).toFloat()
        if (distance > maxDistance) {
            val scale = maxDistance / distance
            return copy(width = translationX * scale, height = normalizedY * scale)
        }
        return copy(width = translationX, height = normalizedY)
    }
}
