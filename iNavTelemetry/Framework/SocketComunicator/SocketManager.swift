//
//  SocketComunicator.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/7/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI
import Combine

protocol SocketProtocol {
    var messageReceived: PassthroughSubject<String, Never> { get }
    
    func start()
    func ping()
    func close()
    func receive()
    func send(data: Data)
}

final class SocketManager: SocketProtocol {
    
    var messageReceived = PassthroughSubject<String, Never>()
    
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession
    private let urlServer: String
    
    init(urlServer: String,
         session: URLSession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)) {
        self.session = session
        self.urlServer = urlServer
    }
    
    func start() {
        guard let url = URL(string: urlServer) else { return }
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        receive()
        ping()
    }
    
    func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("WebSocket ping error: \(error)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [unowned self] in
                ping()
            }
        }
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
    
    func receive() {
        webSocket?.receive { [unowned self] result in
            switch result {
            case let .success(message):
                switch message {
                case let .data(data):
                    print("WebSocket data: \(data)")
                case let .string(string):
                    messageReceived.send(string)
                default:
                    break
                }
                receive()
            case let .failure(error):
                print("WebSocket receive error: \(error)")
            }
        }
    }
    
    func send(data: Data) {
        webSocket?.send(.data(data)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
}
