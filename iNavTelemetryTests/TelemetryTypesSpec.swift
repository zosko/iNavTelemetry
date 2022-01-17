//
//  TelemetryTypesSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/17/22.
//

import XCTest
import CoreLocation

@testable import iNavTelemetry

class TelemetryTypesSpec: XCTestCase {

    func testTelemetryTypes() throws {
        XCTAssertEqual(TelemetryType.smartPort.name, "S.Port")
        XCTAssertEqual(TelemetryType.unknown.name, "Unknown")
        XCTAssertEqual(TelemetryType.msp.name, "MSP")
        XCTAssertEqual(TelemetryType.custom.name, "Custom")
        XCTAssertEqual(TelemetryType.mavLink_v1.name, "MavLink V1")
        XCTAssertEqual(TelemetryType.mavLink_v2.name, "MavLink V2")
    }
    
    func testBluetoothTypes() throws {
        XCTAssertEqual(BluetoothType.hm10.uuidService, "FFE0")
        XCTAssertEqual(BluetoothType.hm10.uuidChar, "FFE1")
        
        XCTAssertEqual(BluetoothType.frskyBuildIn.uuidService, "FFF0")
        XCTAssertEqual(BluetoothType.frskyBuildIn.uuidChar, "FFF6")
        
        XCTAssertEqual(BluetoothType.tbsCrossfire.uuidService, "180F")
        XCTAssertEqual(BluetoothType.tbsCrossfire.uuidChar, "2A19")
    }
    
    func testLogTelemetry() throws {
        let log = LogTelemetry(id: "", lat: 11, lng: 22)
        XCTAssertEqual(CLLocationCoordinate2D(latitude: 11, longitude: 22), log.location)
    }
    
    func testInstrumentTelemetry() throws {
        var packet = Packet()
        packet.flight_mode = 00040
        
        var instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .smartPort)
        XCTAssertEqual(instrumentTelemetry.stabilization, .manual)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Manual")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        packet.flight_mode = 00020
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .smartPort)
        XCTAssertEqual(instrumentTelemetry.stabilization, .horizon)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Horizon")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        packet.flight_mode = 00015
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .smartPort)
        XCTAssertEqual(instrumentTelemetry.stabilization, .angle)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Angle")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
        
        packet.flight_mode = 1
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .msp)
        XCTAssertEqual(instrumentTelemetry.stabilization, .manual)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Manual")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
        
        packet.flight_mode = 4
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .msp)
        XCTAssertEqual(instrumentTelemetry.stabilization, .angle)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Angle")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        packet.flight_mode = 5
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .msp)
        XCTAssertEqual(instrumentTelemetry.stabilization, .angle)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Angle")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
        
        packet.flight_mode = 8
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .msp)
        XCTAssertEqual(instrumentTelemetry.stabilization, .horizon)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Horizon")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        packet.flight_mode = 9
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .msp)
        XCTAssertEqual(instrumentTelemetry.stabilization, .horizon)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Horizon")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
        
        packet.flight_mode = 0
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v1)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v2)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        packet.flight_mode = 128
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v1)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
        
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v2)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
        
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .custom)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .undefined)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Undefined")
    }

}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
