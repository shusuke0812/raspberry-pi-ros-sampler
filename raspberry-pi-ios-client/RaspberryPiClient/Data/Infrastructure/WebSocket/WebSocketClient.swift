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

    /// 単一のストリームを保持し、参照のたびに上書きされないようにする
    private var connectionStatesStream: AsyncStream<WebSocketConnectionState>?
    private var stateContinuation: AsyncStream<WebSocketConnectionState>.Continuation?

    /// 単一のストリームを保持。初回参照時または disconnect 後の connect で生成される
    private var messagesStream: AsyncThrowingStream<String, Error>?
    private var messageContinuation: AsyncThrowingStream<String, Error>.Continuation?

    /// バイナリメッセージ用ストリーム（Foxglove Bridge の Message Data 等）
    private var binaryMessagesStream: AsyncThrowingStream<Data, Error>?
    private var binaryMessageContinuation: AsyncThrowingStream<Data, Error>.Continuation?

    var connectionStates: AsyncStream<WebSocketConnectionState> {
        connectionStatesStream!
    }

    var messages: AsyncThrowingStream<String, Error> {
        if let stream = messagesStream {
            return stream
        }
        let stream = AsyncThrowingStream<String, Error> { [weak self] continuation in
            self?.messageContinuation = continuation
        }
        messagesStream = stream
        return stream
    }

    /// バイナリメッセージのストリーム（Foxglove Bridge の Message Data opcode 0x01 等で使用）
    var binaryMessages: AsyncThrowingStream<Data, Error> {
        if let stream = binaryMessagesStream {
            return stream
        }
        let stream = AsyncThrowingStream<Data, Error> { [weak self] continuation in
            self?.binaryMessageContinuation = continuation
        }
        binaryMessagesStream = stream
        return stream
    }

    override init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let (stream, continuation) = AsyncStream.makeStream(of: WebSocketConnectionState.self)
        self.connectionStatesStream = stream
        self.stateContinuation = continuation
        continuation.yield(.ready)
    }

    /// - Parameter webSocketUrl: 接続先の WebSocket URL（protocols は WebSocketUrl のプロパティで設定）
    func connect(webSocketUrl: WebSocketUrl) {
        timeoutTask?.cancel()

        if messagesStream == nil {
            let stream = AsyncThrowingStream<String, Error> { [weak self] continuation in
                self?.messageContinuation = continuation
            }
            messagesStream = stream
        }
        if binaryMessagesStream == nil {
            let stream = AsyncThrowingStream<Data, Error> { [weak self] continuation in
                self?.binaryMessageContinuation = continuation
            }
            binaryMessagesStream = stream
        }

        stateContinuation?.yield(.connecting)
        let request = webSocketUrl.urlRequest
        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()

        startConnectionTimeout()
    }

    func disconnect() {
        timeoutTask?.cancel()
        timeoutTask = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        finishMessagesStream()
    }

    private func finishMessagesStream() {
        messageContinuation?.finish()
        messageContinuation = nil
        messagesStream = nil
        binaryMessageContinuation?.finish()
        binaryMessageContinuation = nil
        binaryMessagesStream = nil
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
                    print("text=\(text)")
                    messageContinuation?.yield(text)
                case .data(let data):
                    print("data=\(String(data: data, encoding: .utf8))")
                    binaryMessageContinuation?.yield(data)
                @unknown default:
                    assertionFailure("Unexpected receive message type: \(message)")
                }
            }
        } catch {
            // Network errors, WebSocket connection errors
            messageContinuation?.finish(throwing: error)
            binaryMessageContinuation?.finish(throwing: error)
            finishMessagesStream()
        }
    }
    
    private func startConnectionTimeout() {
        timeoutTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: UInt64(self.connectionTimeoutSeconds * 1_000_000_000))
                await MainActor.run {
                    self.stateContinuation?.yield(.connectingTimeout)
                    self.webSocketTask?.cancel(with: .normalClosure, reason: nil)
                    self.webSocketTask = nil
                    self.stateContinuation?.yield(.ready)
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
        
        stateContinuation?.yield(.connected)
        Task { await receiveMessages() }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        stateContinuation?.yield(.disconnected(closeCode: closeCode, reason: reason))
        finishMessagesStream()
    }
}
