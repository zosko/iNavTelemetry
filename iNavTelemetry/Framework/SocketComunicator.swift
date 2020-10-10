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

typealias socketDataReceive = (_ json: Any) -> Void

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
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on(clientEvent: .error) {data, ack in
            print("socket disconnect")
            self.socket.connect()
        }
        socket.on(clientEvent: .statusChange) {data, ack in
            print("socket status: \(data)")
        }
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnect")
        }
        socket.connect()
    }
    
    func planesLocation(completion: @escaping socketDataReceive) {
        socket.on("planesLocation") {data, ack in
            completion(data)
        }
    }
    func sendPlaneLocation(lat : Double, lng : Double){
        socket.emit("planeLocation", with: [["lat":lat,"lng":lng]])
    }
}
