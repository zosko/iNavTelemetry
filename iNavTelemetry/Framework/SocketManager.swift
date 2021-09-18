//
//  SocketComunicator.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/7/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI
import SocketIO
import Combine

class SocketComunicator: NSObject, ObservableObject {
    
    let manager = SocketManager(socketURL: URL(string: "https://deadpan-rightful-aunt.glitch.me")!, config: [.log(false), .compress])
    
    @Published var planes: [Plane] = []
    
    override init() {
        super.init()
        
        manager.defaultSocket.on(clientEvent: .connect) {_, _ in
            print("socket connected")
        }
        manager.defaultSocket.on(clientEvent: .error) {data, _ in
            print("socket disconnect")
        }
        manager.defaultSocket.on(clientEvent: .statusChange) {data, _ in
            print("socket status: \(data)")
        }
        manager.defaultSocket.on(clientEvent: .disconnect) {_, _ in
            print("socket disconnect")
        }
        manager.defaultSocket.on("planesLocation") { [unowned self] data, _ in
            let jsonData = try! JSONSerialization.data(withJSONObject: data[0])
            let decoder = JSONDecoder()
            do {
                let allPlanes = try decoder.decode([TelemetryManager.LogTelemetry].self, from: jsonData)
                self.planes = allPlanes.map { Plane(coordinate: $0.location) }
            } catch {
                print(error)
            }
        }
        
        manager.defaultSocket.connect()
    }
    
    func sendPlaneData(location: TelemetryManager.LogTelemetry){
        manager.defaultSocket.emit("planeLocation",["lat":location.lat,
                                                    "lng":location.lng,
        ])
    }
}
