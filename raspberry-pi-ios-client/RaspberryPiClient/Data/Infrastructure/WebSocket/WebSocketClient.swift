//
//  WebSocketClient.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/10/13.
//

import Foundation

final class WebSocketClient: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var timeoutTask: Task<Void, Never>?
    private let connectionTimeoutSeconds: TimeInterval = 10.0

    private var stateConnection: AsyncStream<WebSocketConnectionState>.Continuation?
    var connectionStates: AsyncStream<WebSocketConnectionState> {
        AsyncStream { continuation in
            self.stateConnection = continuation
        }
    }

    private var messageContinuation: AsyncThrowingStream<String, Error>.Continuation?
    var messages: AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            self.messageContinuation = continuation
            return ()
        }
    }

    override init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    // TODO: ROSBridgeと接続するにはApp Transport Securityの設定が必要かも
    func connect(webSocketUrl: WebSocketUrl) {
        timeoutTask?.cancel()
        
        stateConnection?.yield(.connecting)
        webSocketTask = session?.webSocketTask(with: webSocketUrl.url)
        webSocketTask?.resume()
        
        startConnectionTimeout()
    }

    func disconnect() {
        timeoutTask?.cancel()
        timeoutTask = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        messageContinuation?.finish()
    }

    func send(text: String) async throws {
        try await webSocketTask?.send(.string(text))
    }

    func send(data: Data) async throws {
        try await webSocketTask?.send(.data(data))
    }

    private func receiveMessages() async {
        guard let task = webSocketTask else {
            return
        }
        do {
            while true {
                let message = try await task.receive()
                switch message {
                case .string(let text):
                    messageContinuation?.yield(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        messageContinuation?.yield(text)
                    }
                @unknown default:
                    assertionFailure("Unexpected receive message type: \(message)")
                }
            }
        } catch {
            messageContinuation?.finish(throwing: error)
        }
    }
    
    private func startConnectionTimeout() {
        timeoutTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: UInt64(self.connectionTimeoutSeconds * 1_000_000_000))
                await MainActor.run {
                    self.stateConnection?.yield(.connectingTimeout)
                    self.webSocketTask?.cancel(with: .normalClosure, reason: nil)
                    self.webSocketTask = nil
                    self.stateConnection?.yield(.ready)
                }
            } catch {
                // do nothing
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        timeoutTask?.cancel()
        timeoutTask = nil
        
        stateConnection?.yield(.connected)
        Task { await receiveMessages() }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        stateConnection?.yield(.disconnected(closeCode: closeCode, reason: reason))
        messageContinuation?.finish()
    }
}
