//
//  SocketComunicator.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/7/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI
import Combine

final class SocketComunicator: NSObject, ObservableObject {
    @Published private(set) var planes: [Plane] = []
    
    private var webSocket: URLSessionWebSocketTask?
    private let uniqUUID = UUID().uuidString
    
    // MARK: - Initialization
    override init() {
        super.init()
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        if let url = URL(string: "ws://localhost:8080") {
            webSocket = session.webSocketTask(with: url)
            webSocket?.resume()
            
            receive()
            ping()
        }
    }
    
    // MARK: - Private methods
    private func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                self.webSocket = nil
                print("WebSocket ping error: \(error)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.ping()
            }
        }
    }
    private func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
    private func receive() {
        webSocket?.receive { result in
            switch result {
            case let .success(message):
                switch message {
                case let .data(data):
                    print("WebSocket data: \(data)")
                case let .string(string):
                    if let jsonData = string.data(using: .utf8),
                       let allPlanes = try? JSONDecoder().decode([LogTelemetry].self,
                                                                 from: jsonData) {
                        self.planes = allPlanes.map {
                            Plane(id: $0.id, coordinate: $0.location, mine: $0.id == self.uniqUUID)
                        }.filter{
                            return $0.id != self.uniqUUID
                        }
                    } else {
                        print("WebSocket JSONDecoder problem")
                    }
                default:
                    break
                }
                self.receive()
            case let .failure(error):
                print("WebSocket receive error: \(error)")
                self.webSocket = nil
            }
        }
    }
    func send(_ data: Data) {
        webSocket?.send(.data(data)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    // MARK: - Internal methods
    func sendPlaneData(location: LogTelemetry){
        let dataToSend = LogTelemetry(id: self.uniqUUID, lat: location.lat, lng: location.lng)
        guard let data = try? JSONEncoder().encode(dataToSend) else { return }
        self.send(data)
    }
}
