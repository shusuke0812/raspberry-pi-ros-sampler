package com.shusuke.raspberry_pi_client.data.infrastructure.ros.service

import kotlinx.serialization.Serializable

/**
 * [std_srvs/srv/Empty.srv](https://github.com/ros2/common_interfaces/blob/jazzy/std_srvs/srv/Empty.srv)
 *
 * 引数・レスポンスともに空のサービス型。
 * `/reset` 等で使用。
 */
@Serializable
object EmptyService
