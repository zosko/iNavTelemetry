//
//  Telemetry.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/31/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import CoreBluetooth
import MapKit

class TelemetryManager: NSObject {
    
    enum TelemetryType: Int {
        case smartPort = 0
        case msp = 1
        case custom = 2
        
        var name: String {
            switch self {
            case .smartPort:
                return "S.Port"
            case .msp:
                return "MSP"
            case .custom:
                return "Custom"
            }
        }
    }

    enum BluetoothType : Int {
        case hm10 = 0
        case frskyBuildIn = 1
    }

    enum BluetoothUUID : String {
        case hm10Service = "FFE0"
        case hm10Char = "FFE1" //write
        case frskyService = "FFF0"
        case frskyChar = "FFF6" //write
    }
    
    enum Stabilization : String {
        case undefined
        case manual
        case horizon
        case angle
        
        var name: String { return self.rawValue.capitalized }
    }
    
    enum Engine: String {
        case undefined
        case disarmed
        case armed
        
        var name: String { return self.rawValue.capitalized }
    }

    struct Packet {
        var lat: Double = 0.0
        var lng: Double = 0.0
        var alt: Int = 0
        var gps_sats: Int = 0
        var distance: Int = 0
        var speed: Int = 0
        var voltage: Double = 0.0
        var rssi: Int = 0
        var current: Int = 0
        var heading: Int = 0
        var flight_mode: Int = 0
        var fuel: Int = 0
        var roll: Int = 0
        var pitch: Int = 0
    }
    
    struct LogTelemetry: Codable {
        var lat: Double = 0.0
        var lng: Double = 0.0
    }
    
    struct InstrumentTelemetry {
        var packet: Packet
        
        var flyTime: Int = 0
        var telemetryType: TelemetryType = .smartPort
        var location: CLLocationCoordinate2D {
            .init(latitude: packet.lat, longitude: packet.lng)
        }
        var stabilization: Stabilization {
            switch telemetryType {
            case .smartPort:
                let mode = packet.flight_mode / 10 % 10
                switch mode {
                case 1: return .angle
                case 2: return .horizon
                default: return .manual
                }
            case .msp:
                let flags = packet.flight_mode
                switch flags {
                case 4, 5: return .angle
                case 8, 9: return .horizon
                default: return .manual
                }
            case .custom:
                return .undefined
            }
        }
        var engine: Engine {
            switch telemetryType {
            case .smartPort:
                let mode = packet.flight_mode % 10
                return mode == 5 ? .armed : .disarmed
            case .msp:
                let flags = packet.flight_mode
                return (flags == 1 || flags == 5 || flags == 9) ? .armed : .disarmed
            case .custom:
                return .undefined
            }
        }
        
        init(packet: Packet, telemetryType: TelemetryType, flyTime: Int) {
            self.packet = packet
            self.telemetryType = telemetryType
            self.flyTime = flyTime
        }
    }
    
    
    private var smartPort = SmartPort()
    private var custom = CustomTelemetry()
    private var msp = MSP_V1()
    
    private var _packet = Packet()
    private var _telemetryType: TelemetryType = .smartPort
    private var _bluetoothType: BluetoothType = .frskyBuildIn
    private var _flyTime = 0
    
    var telemetryType: TelemetryType { return _telemetryType }
    var bluetoothType: BluetoothType { return _bluetoothType }
    var telemetry: InstrumentTelemetry { InstrumentTelemetry(packet: _packet,
                                                             telemetryType: _telemetryType,
                                                             flyTime: _flyTime) }
    
    func chooseTelemetry(type: TelemetryType){
        self._telemetryType = type
    }
    
    func requestTelemetry(peripheral: CBPeripheral, characteristic: CBCharacteristic, writeType: CBCharacteristicWriteType) {
        switch _telemetryType {
        case .custom:
            break
        case .smartPort:
            break
        case .msp:
            peripheral.writeValue(msp.request(messageID: .MSP_STATUS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_RAW_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_COMP_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_ATTITUDE), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_ANALOG), for: characteristic, type: writeType)
        }
    }
    
    func parse(incomingData: Data) -> Bool{
        switch _telemetryType {
        case .custom:
            if custom.process_incoming_bytes(incomingData: incomingData) {
                _packet = custom.packet
                return true
            }
            return false
        case .smartPort:
            if smartPort.process_incoming_bytes(incomingData: incomingData) {
                _packet = smartPort.packet
                return true
            }
            return false
        case .msp:
            if msp.process_incoming_bytes(incomingData: incomingData) {
                _packet = msp.packet
                return true
            }
            return false
        }
    }
    
}
