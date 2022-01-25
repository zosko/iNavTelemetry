//
//  SocketComunicator.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 25.1.22.
//

import Foundation
import Combine

final class SocketComunicator: ObservableObject {
    @Published private(set) var planes: [Plane] = []
    
    private let socketManager: SocketProtocol
    private let uniqUUID: String
    
    // MARK: - Initialization
    init(socketManager: SocketProtocol = SocketManager(urlServer: "ws://localhost:8080"),
         uniqUUID: String = UUID().uuidString) {
        self.socketManager = socketManager
        self.uniqUUID = uniqUUID
        
        self.socketManager.start()
        setupBindings()
    }
    
    // MARK: - Private methods
    private func setupBindings() {
        socketManager
            .messageReceived
            .compactMap({ $0.data(using: .utf8) })
            .decode(type: [LogTelemetry].self, decoder: JSONDecoder())
            .map({ logs in
                return logs.map {
                    Plane(id: $0.id, coordinate: $0.location, mine: $0.id == self.uniqUUID)
                }.filter {
                    return $0.id != self.uniqUUID
                }
            })
            .replaceError(with: [])
            .assign(to: &$planes)
            
    }
    
    // MARK: - Internal methods
    func sendPlaneData(location: LogTelemetry) {
        let dataToSend = LogTelemetry(id: self.uniqUUID, lat: location.lat, lng: location.lng)
        guard let data = try? JSONEncoder().encode(dataToSend) else { return }
        socketManager.send(data: data)
    }
}
