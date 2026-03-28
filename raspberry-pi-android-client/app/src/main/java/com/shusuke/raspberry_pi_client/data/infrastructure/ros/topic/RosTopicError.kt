package com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic

/**
 * ROS トピック関連のエラー
 */
sealed class RosTopicError(
    override val message: String,
) : Exception(message) {

    /** すでに購読済みのトピック */
    data object AlreadySubscribed : RosTopicError("すでに購読済みのトピックです")

    /** トピックが advertise されていない */
    data object ChannelNotFound : RosTopicError("トピックが advertise されていません")

    /** メッセージの受信に失敗 */
    data class FailedReceiveMessage(val reason: Throwable) : RosTopicError(
        "メッセージの受信に失敗しました: ${reason.message ?: reason.toString()}",
    )

    /** メッセージをデータ型に変換できなかった */
    data object FailedConvertStringToData : RosTopicError("メッセージをデータ型に変換できませんでした")

    /** メッセージの変換に失敗 */
    data class FailedDecodeMessage(val reason: Throwable) : RosTopicError(
        "メッセージの変換に失敗しました: ${reason.message ?: reason.toString()}",
    )
}
