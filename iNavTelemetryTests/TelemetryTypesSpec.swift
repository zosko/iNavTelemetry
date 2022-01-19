//
//  TelemetryTypesSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/17/22.
//

import XCTest
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
    
    func testInstrumentType() throws {        
        XCTAssertEqual(InstrumentType.latitude.name,"Latitude")
        XCTAssertEqual(InstrumentType.latitude.imageName,"network")
        
        XCTAssertEqual(InstrumentType.longitude.name,"Longitude")
        XCTAssertEqual(InstrumentType.longitude.imageName,"network")
        
        XCTAssertEqual(InstrumentType.satellites.name,"Satellites")
        XCTAssertEqual(InstrumentType.satellites.imageName,"bonjour")
        
        XCTAssertEqual(InstrumentType.distance.name,"Distance")
        XCTAssertEqual(InstrumentType.distance.imageName,"shuffle")
        
        XCTAssertEqual(InstrumentType.altitude.name,"Altitude")
        XCTAssertEqual(InstrumentType.altitude.imageName,"mount")
        
        XCTAssertEqual(InstrumentType.galtitude.name,"GPS Alt")
        XCTAssertEqual(InstrumentType.galtitude.imageName,"mount")
        
        XCTAssertEqual(InstrumentType.speed.name,"Speed")
        XCTAssertEqual(InstrumentType.speed.imageName,"speedometer")
        
        XCTAssertEqual(InstrumentType.armed.name,"Engine")
        XCTAssertEqual(InstrumentType.armed.imageName,"shield")
        
        XCTAssertEqual(InstrumentType.signal.name,"Signal")
        XCTAssertEqual(InstrumentType.signal.imageName,"antenna.radiowaves.left.and.right")
        
        XCTAssertEqual(InstrumentType.fuel.name,"Fuel")
        XCTAssertEqual(InstrumentType.fuel.imageName,"fuelpump")
        
        XCTAssertEqual(InstrumentType.flymode.name,"Fly mode")
        XCTAssertEqual(InstrumentType.flymode.imageName,"airplane.circle")
        
        XCTAssertEqual(InstrumentType.flytime.name,"Fly time")
        XCTAssertEqual(InstrumentType.flytime.imageName,"timer")
        
        XCTAssertEqual(InstrumentType.current.name,"Current")
        XCTAssertEqual(InstrumentType.current.imageName,"directcurrent")
        
        XCTAssertEqual(InstrumentType.voltage.name,"Voltage")
        XCTAssertEqual(InstrumentType.voltage.imageName,"minus.plus.batteryblock")
    }
    
}
