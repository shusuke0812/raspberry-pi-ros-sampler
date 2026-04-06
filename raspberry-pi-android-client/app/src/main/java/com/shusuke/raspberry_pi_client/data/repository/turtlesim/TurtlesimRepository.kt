package com.shusuke.raspberry_pi_client.data.repository.turtlesim

import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.EmptyService
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosCallService
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceError
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.service.RosServiceResponse
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.RosTopicPublish
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message.TwistMessage
import com.shusuke.raspberry_pi_client.data.infrastructure.ros.topic.message.Vector3Message
import com.shusuke.raspberry_pi_client.data.repository.connection.RosConnectionRepository
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

/**
 * [ROS Turtlesim](https://wiki.ros.org/turtlesim) のサービス・トピックを操作するリポジトリ。
 *
 * - [spawnTurtle] → `/spawn` サービス
 * - [moveTurtle] → `/turtle2/cmd_vel` (geometry_msgs/msg/Twist)
 * - [reset] → `/reset` サービス
 */
class TurtlesimRepository(
    private val connectionRepository: RosConnectionRepository,
) {
    private val turtleName = "turtle2"

    private val cmdVelSchemaName = "geometry_msgs/msg/Twist"

    /**
     * カメをスポーンする。
     *
     * [Spawn Request](https://docs.ros.org/en/api/turtlesim/html/srv/Spawn.html)
     *
     * @return 成功時は Unit、失敗時は [RosServiceError] を throw
     */
    suspend fun spawnTurtle(x: Float, y: Float, theta: Float): Result<Unit> =
        suspendCancellableCoroutine { cont ->
            val arg = TurtlesimServiceArgs(x = x, y = y, theta = theta, name = turtleName)
            val callService = RosCallService<TurtlesimServiceArgs>(
                service = "/spawn",
                args = arg,
            )
            connectionRepository.activeMessageClient.callService(
                service = callService,
                argsSerializer = TurtlesimServiceArgs.serializer(),
                responseSerializer = RosServiceResponse.serializer(TurtlesimServiceResponse.serializer()),
                cdrEncoder = { TurtlesimServiceArgs.encodeToCdr(it) },
                cdrResponseDecoder = { TurtlesimServiceResponse.decodeFromCdr(it) ?: TurtlesimServiceResponse() },
                onMessage = { result ->
                    result.fold(
                        onSuccess = { cont.resume(Result.success(Unit)) },
                        onFailure = { cont.resume(Result.failure(it as RosServiceError)) },
                    )
                },
            )
        }

    /**
     * カメを移動する。
     *
     * `/turtle2/cmd_vel` に [TwistMessage] を publish する。
     *
     * - [m/s] linear.x = 前進、-linear.x = 後退、linear.y/z = 無効
     * - [rad/s] angular.z = ヨー回転、angular.x/y = 無効
     *
     * @param x 並進速度 [m/s]
     * @param y 未使用（0 に固定）
     * @param radian 角速度 [rad/s]
     */
    fun moveTurtle(x: Float, y: Float, radian: Float) {
        val message = TwistMessage(
            linear = Vector3Message(x = x.toDouble(), y = 0.0, z = 0.0),
            angular = Vector3Message(x = 0.0, y = 0.0, z = radian.toDouble()),
        )
        val topic = RosTopicPublish(
            topic = "/$turtleName/cmd_vel",
            message = message,
        )
        connectionRepository.activeMessageClient.publish(
            topic = topic,
            messageSerializer = TwistMessage.serializer(),
            schemaName = cmdVelSchemaName,
        )
    }

    /**
     * Turtlesim をリセットする。
     *
     * `/reset` サービスを呼び出す。レスポンスは特に扱わない。
     */
    fun reset() {
        val callService = RosCallService<EmptyService>(
            service = "/reset",
            args = EmptyService,
        )
        connectionRepository.activeMessageClient.callService(
            service = callService,
            argsSerializer = EmptyService.serializer(),
            responseSerializer = RosServiceResponse.serializer(EmptyService.serializer()),
            onMessage = { /* レスポンスは無視 */ },
        )
    }
}
