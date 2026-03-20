//
//  FoxgloveMessageOperation.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/03/20.
//

import Foundation

/// Foxglove WebSocket プロトコルの JSON メッセージ種別（JSONの”op”フィールド）
/// Ref: https://github.com/foxglove/ws-protocol/blob/main/docs/spec.md
enum FoxgloveMessageOperation: String, Codable {
    // Server → Client
    case serverInfo = "serverInfo"
    case status
    case removeStatus = "removeStatus"
    case advertise
    case unadvertise
    case parameterValues = "parameterValues"
    case advertiseServices = "advertiseServices"
    case unadvertiseServices = "unadvertiseServices"
    case connectionGraphUpdate = "connectionGraphUpdate"
    case serviceCallFailure = "serviceCallFailure"

    // Client → Server
    case subscribe
    case unsubscribe
    case getParameters = "getParameters"
    case setParameters = "setParameters"
    case subscribeParameterUpdates = "subscribeParameterUpdates"
    case unsubscribeParameterUpdates = "unsubscribeParameterUpdates"
    case subscribeConnectionGraph = "subscribeConnectionGraph"
    case unsubscribeConnectionGraph = "unsubscribeConnectionGraph"
    case fetchAsset = "fetchAsset"
}
