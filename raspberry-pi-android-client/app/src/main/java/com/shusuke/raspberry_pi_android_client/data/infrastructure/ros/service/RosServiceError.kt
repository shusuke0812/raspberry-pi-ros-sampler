package com.shusuke.raspberry_pi_android_client.data.infrastructure.ros.service

/**
 * ROS サービス呼び出し関連のエラー
 */
sealed class RosServiceError(
    override val message: String,
) : Exception(message) {

    data object AlreadyCalling : RosServiceError("すでに同じサービスを呼び出し中です")

    data class FailedReceiveMessage(val reason: Throwable) : RosServiceError(
        "サービスの送信に失敗しました: ${reason.message ?: reason.toString()}",
    )

    data class FailedDecodeMessage(val reason: Throwable) : RosServiceError(
        "レスポンスの変換に失敗しました: ${reason.message ?: reason.toString()}",
    )
}
