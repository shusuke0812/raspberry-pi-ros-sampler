//
//  TurtlesimRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

/// [ROS Turtlesim Doc](https://wiki.ros.org/turtlesim)
protocol TurtlesimRepositoryProtocol {
    func callSpawn(x: Float, y: Float, theta: Float, onMessage: @escaping (Result<Void, RosServiceError>) -> Void)
}

class TurtlesimRepository: TurtlesimRepositoryProtocol {
    private let rosBridgeClient: RosBridgeMessageProtocol

    init(rosBridgeClient: RosBridgeMessageProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    /// [Spawn Request](https://docs.ros.org/en/api/turtlesim/html/srv/Spawn.html)
    func callSpawn(x: Float, y: Float, theta: Float, onMessage: @escaping (Result<Void, RosServiceError>) -> Void) {
        let arg = TurtlesimServiceArgs(x: x, y: y, theta: theta, name: nil)
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
}
