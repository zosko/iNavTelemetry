//
//  SocketCommunicatorSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 25.1.22.
//

import XCTest
import Combine
@testable import iNavTelemetry

class SocketManagerMock: SocketProtocol {
    var messageReceived = PassthroughSubject<String, Never>()
    
    func start() {
        
    }
    
    func ping() { }
    
    func close() { }
    
    func receive() {
        messageReceived.send("[{\"id\": \"1\", \"lat\": 10.0, \"lng\": 10.0},{\"id\": \"2\", \"lat\": 20.0, \"lng\": 20.0},{\"id\": \"3\", \"lat\": 20.0, \"lng\": 20.0}]")
    }
    
    func send(data: Data) {
        
    }
    
}

class SocketCommunicatorSpec: XCTestCase {


    func testSockets() throws {
        let managerMock = SocketManagerMock()
        
        let socketCommunicator = SocketCommunicator(socketManager: managerMock, uniqUUID: "3")
        
        let plane1 = Plane(id: "1", coordinate: .init(latitude: 10.0, longitude: 10.0), mine: false)
        let plane2 = Plane(id: "2", coordinate: .init(latitude: 20.0, longitude: 20.0), mine: false)
        _ = Plane(id: "3", coordinate: .init(latitude: 30.0, longitude: 30.0), mine: true)
        
        managerMock.receive()
        
        XCTAssertEqual(socketCommunicator.planes, [plane1,plane2])
        
        socketCommunicator.sendPlaneData(location: .init(id: "3", lat: 30.0, lng: 30.0))
    }
}

extension Plane: Equatable { }

public func ==(lhs: Plane, rhs: Plane) -> Bool {
    return lhs.id == rhs.id &&
    lhs.coordinate == rhs.coordinate &&
    lhs.mine == rhs.mine
}
