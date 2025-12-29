//
//  TurtlesimRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

/// [ROS Turtlesim Doc](https://wiki.ros.org/turtlesim)
protocol TurtlesimRepositoryProtocol {
    func spawnTurtle(x: Float, y: Float, theta: Float, onMessage: @escaping (Result<Void, RosServiceError>) -> Void)
    func moveTurtle(x: Float, y: Float, theta: Float)
    func reset()
}

class TurtlesimRepository: TurtlesimRepositoryProtocol {
    private let rosBridgeClient: RosBridgeMessageProtocol
    private let turtleName = "turtle2"

    init(rosBridgeClient: RosBridgeMessageProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    /// [Spawn Request](https://docs.ros.org/en/api/turtlesim/html/srv/Spawn.html)
    func spawnTurtle(x: Float, y: Float, theta: Float, onMessage: @escaping (Result<Void, RosServiceError>) -> Void) {
        let arg = TurtlesimServiceArgs(x: x, y: y, theta: theta, name: turtleName)
        let callService = RosCallService<TurtlesimServiceArgs, TurtlesimServiceResponse>(
            service: "/spawn",
            arg: arg
        )
        rosBridgeClient.callService(service: callService) { result in
            switch result {
            case .success(_):
                onMessage(.success(()))
            case .failure(let error):
                onMessage(.failure(error))
            }
        }
    }

    func moveTurtle(x: Float, y: Float, theta: Float) {
        let message = TwistMessage(
            linear: Vector3Message(x: Double(x), y: Double(y), z: 0),
            angular: Vector3Message(x: 0, y: 0, z: Double(theta))
        )
        let topic = RosTopicPublish<TwistMessage>(
            topic: "/\(turtleName)/cmd_vel",
            message: message
        )
        rosBridgeClient.publish(topic: topic)
    }

    func reset() {
        let arg = EmptyService()
        let callService = RosCallService<EmptyService, EmptyService>(
            service: "/reset",
            arg: arg
        )
        rosBridgeClient.callService(service: callService) { result in
            // do nothing
        }
    }
}
