//
//  TurtlesimServiceArgs.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import Foundation

struct TurtlesimServiceArgs: RosCallServiceArgsProtocol, RosCallServiceCdrEncodable {
    let x: Float
    let y: Float
    let theta: Float
    let name: String?

    func encodeCdr() -> Data {
        var data = Data(CdrHelpers.encapsulationHeader)
        data.append(contentsOf: withUnsafeBytes(of: x.bitPattern.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: y.bitPattern.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: theta.bitPattern.littleEndian) { Array($0) })
        data.append(contentsOf: CdrHelpers.encodeCdrString(name))
        return data
    }
}
