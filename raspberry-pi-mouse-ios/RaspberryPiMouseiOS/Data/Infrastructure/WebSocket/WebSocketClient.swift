//
//  WebSocketClient.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/13.
//

import Foundation

protocol WebSocketClientProtocol {
    func connect()
    func disconnect()
    func send(text: String, completion: (() -> Void)?)
    func send(data: Data, completion: (() -> Void)?)
}

protocol WebSocketClientDelegate: AnyObject {
    func webSocketClient(didConnect client: WebSocketClient)
    func webSocketClient(didDisconnect client: WebSocketClient)
    func webSocketClient(_ client: WebSocketClient, didReceiveText text: String)
    func webSocketClient(_ client: WebSocketClient, didReceiveDat data: Data)
    func webSocketClient(_ client: WebSocketClient, didReceiveError error: Error)
    func webSocketClient(_ client: WebSocketClient, failedSendingMessageError error: Error?)
}

class WebSocketClient: WebSocketClientProtocol {
    weak var delegate: WebSocketClientDelegate?

    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private let url: URL

    init(urlString: String) {
        self.session = URLSession.shared
        self.url = URL(string: urlString)!
    }

    // TODO: ROSBridgeと接続するにはApp Transport Securityの設定が必要かも
    func connect() {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        delegate?.webSocketClient(didConnect: self)

        receiveMessage()
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let messageString):
                    self.delegate?.webSocketClient(self, didReceiveText: messageString)
                case .data(let messageData):
                    self.delegate?.webSocketClient(self, didReceiveDat: messageData)
                @unknown default:
                    assertionFailure("Unexpected receive message type: \(message)")
                }
            case .failure(let error):
                self.delegate?.webSocketClient(self, didReceiveError: error)
                return
            }
            self.receiveMessage()
        }
    }

    // TODO: 切断理由（closeCode）を引数で渡す
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        delegate?.webSocketClient(didDisconnect: self)
    }

    func send(text: String, completion: (() -> Void)?) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { [weak self] error in
            guard let self else { return }
            self.delegate?.webSocketClient(self, failedSendingMessageError: error)
        }
    }

    func send(data: Data, completion: (() -> Void)?) {
        let message = URLSessionWebSocketTask.Message.data(data)
        webSocketTask?.send(message) { [weak self] error in
            guard let self else { return }
            self.delegate?.webSocketClient(self, failedSendingMessageError: error)
        }
    }
}
