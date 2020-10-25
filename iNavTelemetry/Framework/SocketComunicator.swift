//
//  SocketComunicator.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/7/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif
import SocketIO

typealias socketDataReceive = (_ planes: [PlaneData]) -> Void

class SocketComunicator: NSObject {
    static let shared = SocketComunicator()
    var manager : SocketManager!
    var socket: SocketIOClient!
    
    override init() {
        super.init()
    }
    
    func socketConnectionSetup() {
        manager = SocketManager(socketURL: URL(string: "https://deadpan-rightful-aunt.glitch.me")!, config: [.log(false), .compress])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {_, _ in
            print("socket connected")
        }
        socket.on(clientEvent: .error) {_, _ in
            print("socket disconnect")
        }
        socket.on(clientEvent: .statusChange) {data, _ in
            print("socket status: \(data)")
        }
        socket.on(clientEvent: .disconnect) {_, _ in
            print("socket disconnect")
        }
        socket.connect()
    }
    
    func planesLocation(completion: @escaping socketDataReceive) {
        socket.on("planesLocation") { (data, _) in
            let jsonData = try! JSONSerialization.data(withJSONObject: data[0])
            let decoder = JSONDecoder()
            do {
                let planes = try decoder.decode([PlaneData].self, from: jsonData)
                completion(planes)
            } catch {
                print(error)
            }
        }
    }
    func sendPlaneData(packet: SmartPortStruct, photo : String = ""){
        socket.emit("planeLocation", with: [["lat":packet.lat,
                                             "lng":packet.lng,
                                             "alt":packet.alt,
                                             "speed":packet.speed,
                                             "heading":packet.heading,
                                             "photo": photo
        ]])
    }
}
