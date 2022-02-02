//
//  SmartPortSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest
@testable import iNavTelemetry

final class SmartPortMock: TelemetryProtocol {
    var packet = Packet()
    
    var packetValidation = false
    
    func process(_ incomingData: Data) -> Bool {
        packetValidation
    }
}

class SmartPortSpec: XCTestCase {

    func testSmartPort() throws {
        let smartPort = SmartPortMock()
        
        XCTAssertFalse(smartPort.process(Data()))
        smartPort.packetValidation = true
        
        XCTAssertTrue(smartPort.process(Data()))
        
        let bufferIn: [UInt8] = [0x01,0x02,0x03,0x04]
        
        XCTAssertEqual(smartPort.littleEndian_get_int16(buffer: bufferIn, index: 1), 0x0201)
        XCTAssertEqual(smartPort.littleEndian_get_int32(buffer: bufferIn, index: 3), 0x04030201)
    }

}
