//
//  TurtlesimRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

protocol TurtlesimRepositoryProtocol {
    func callSpawn(x: Float, y: Float, theta: Float)
}

class TurtlesimRepository: TurtlesimRepositoryProtocol {
    private let rosBridgeClient: RosBridgeServiceProtocol

    init(rosBridgeClient: RosBridgeServiceProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func callSpawn(x: Float, y: Float, theta: Float) {
        let arg = TurtlesimServiceArgs(x: x, y: y, theta: theta, name: nil)
        let callService = RosCallService<TurtlesimServiceArgs, TurtlesimServiceResponse>(
            service: "turtlesim/Spawn",
            args: [arg]
        )
        rosBridgeClient.callService(service: callService) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}
