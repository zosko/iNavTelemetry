//
//  TelemetryDataSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest
import CoreLocation
@testable import iNavTelemetry

class TelemetryDataSpec: XCTestCase {

    func testLogTelemetry() throws {
        let log = LogTelemetry(id: "", lat: 11, lng: 22)
        XCTAssertEqual(CLLocationCoordinate2D(latitude: 11, longitude: 22), log.location)
    }
    
    func testInstrumentTelemetrySmartPort() throws {
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
    }
    
    func testInstrumentTelemetryMSP() throws {
        var packet = Packet()
        
        packet.flight_mode = 1
        var instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .msp)
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
    }
    
    func testInstrumentTelemetryMavLinkV1() throws {
        var packet = Packet()
        
        packet.flight_mode = 0
        var instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v1)
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
    }
    
    func testInstrumentTelemetryMavLinkV2() throws {
        var packet = Packet()
        
        packet.flight_mode = 0
        var instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v2)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .disarmed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Disarmed")
        
        packet.flight_mode = 128
        instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .mavLink_v2)
        XCTAssertEqual(instrumentTelemetry.stabilization, .undefined)
        XCTAssertEqual(instrumentTelemetry.engine, .armed)
        XCTAssertEqual(instrumentTelemetry.stabilization.name, "Undefined")
        XCTAssertEqual(instrumentTelemetry.engine.name, "Armed")
    }
    
    func testInstrumentTelemetryMavLinkCustom() throws {
        let packet = Packet()
        
        let instrumentTelemetry = InstrumentTelemetry(packet: packet, telemetryType: .custom)
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
