//
//  TurtlesimRepository.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

protocol TurtlesimRepositoryProtocol {
    func callSpawn()
}

class TurtlesimRepository: TurtlesimRepositoryProtocol {
    private let rosBridgeClient: RosBridgeServiceProtocol

    init(rosBridgeClient: RosBridgeServiceProtocol = RosBridgeClient.shared) {
        self.rosBridgeClient = rosBridgeClient
    }

    func callSpawn() {
    }
}
