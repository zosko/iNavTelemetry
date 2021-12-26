//
//  Telemetry.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/31/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import CoreBluetooth
import MapKit

class TelemetryManager: NSObject, ObservableObject {
    
    enum TelemetryType {
        case unknown
        case smartPort
        case msp
        case custom
        case mavLink_v1
        case mavLink_v2
        
        var name: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .smartPort:
                return "S.Port"
            case .msp:
                return "MSP"
            case .custom:
                return "Custom"
            case .mavLink_v1:
                return "MavLink V1"
            case .mavLink_v2:
                return "MavLink V2"
            }
            
        }
    }

    enum BluetoothType : Int {
        case hm10 = 0
        case frskyBuildIn = 1
        case tbsCrossfire = 2
    }

    enum BluetoothUUID : String {
        case hm10Service = "FFE0"
        case hm10Char = "FFE1" //write
        
        case frskyService = "FFF0"
        case frskyChar = "FFF6" //write
        
        case tbsCrossfireService = "180F"
        case tbsCrossfireChar = "2A19" //write
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
        var id: String = ""
        var lat: Double = 0.0
        var lng: Double = 0.0
        
        var location: CLLocationCoordinate2D {
            .init(latitude: lat, longitude: lng)
        }
    }
    
    struct InstrumentTelemetry {
        var packet: Packet
        
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
            case .mavLink_v1, .mavLink_v2:
                return .undefined
            case .unknown:
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
            case .mavLink_v1, .mavLink_v2:
                let flags = packet.flight_mode
                return flags == 128 ? .armed : .disarmed
            case .unknown:
                return .undefined
            }
        }
        
        init(packet: Packet, telemetryType: TelemetryType) {
            self.packet = packet
            self.telemetryType = telemetryType
        }
    }
    
    private let smartPort = SmartPort()
    private let custom = Custom()
    private let msp = MSP_V1()
    private let mavLink_v1 = MavLink_v1()
    private let mavLink_v2 = MavLink_v2()
    private var packet = Packet() {
        didSet {
            telemetry = InstrumentTelemetry(packet: packet, telemetryType: telemetryType)
        }
    }
    private var telemetryType: TelemetryType = .unknown
    private var protocolDetector: [TelemetryType] = []
    private var timerRequestMSP: Timer?
    private var bluetoothManager: BluetoothManager?
    
    @Published var telemetry: InstrumentTelemetry = .init(packet: .init(), telemetryType: .smartPort)
    
    //MARK: - Internal functions
    func stopTelemetry() {
        self.telemetryType = .unknown
        self.protocolDetector = []
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
    }
    func addBluetoothManager(bluetoothManager: BluetoothManager){
        self.bluetoothManager = bluetoothManager
    }
    func parse(incomingData: Data) -> Bool{
        switch telemetryType {
        case .unknown:
            let hits = detectProtocol(incomingData: incomingData)
            if hits.count > 15 {
                if let result = mostFrequent(array: protocolDetector) {
                    self.telemetryType = result.value
                }
                if self.telemetryType == .msp {
                    mspRequest(requesting: true)
                }
                protocolDetector = []
            }
            return false
        case .custom:
            if custom.process_incoming_bytes(incomingData: incomingData) {
                packet = custom.packet
                return true
            }
            return false
        case .smartPort:
            if smartPort.process_incoming_bytes(incomingData: incomingData) {
                packet = smartPort.packet
                return true
            }
            return false
        case .msp:
            if msp.process_incoming_bytes(incomingData: incomingData) {
                packet = msp.packet
                return true
            }
            return false
        case .mavLink_v1:
            if mavLink_v1.process_incoming_bytes(incomingData: incomingData) {
                packet = mavLink_v1.packet
                return true
            }
            return false
        case .mavLink_v2:
            if mavLink_v2.process_incoming_bytes(incomingData: incomingData) {
                packet = mavLink_v2.packet
                return true
            }
            return false
        }
    }

    //MARK: - Private functions
    private func detectProtocol(incomingData: Data) -> [TelemetryType]{
        var receivedUnknown = true
        if let manager = self.bluetoothManager,
           let writeChars = manager.writeCharacteristic,
           let peripheral = manager.connectedPeripheral {
            peripheral.writeValue(msp.request(messageID: .MSP_STATUS),
                                  for: writeChars,
                                  type: manager.writeTypeCharacteristic)
        }
        
        if custom.process_incoming_bytes(incomingData: incomingData) {
            protocolDetector.append(.custom)
            receivedUnknown = false
        }
        if smartPort.process_incoming_bytes(incomingData: incomingData) {
            protocolDetector.append(.smartPort)
            receivedUnknown = false
        }
        if msp.process_incoming_bytes(incomingData: incomingData) {
            protocolDetector.append(.msp)
            receivedUnknown = false
        }
        if mavLink_v1.process_incoming_bytes(incomingData: incomingData) {
            protocolDetector.append(.mavLink_v1)
            receivedUnknown = false
        }
        if mavLink_v2.process_incoming_bytes(incomingData: incomingData) {
            protocolDetector.append(.mavLink_v2)
            receivedUnknown = false
        }
        
        if receivedUnknown {
            protocolDetector.append(.unknown)
        }
        
        return protocolDetector
    }
    private func mostFrequent<T: Hashable>(array: [T]) -> (value: T, count: Int)? {
        let counts = array.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        if let (value, count) = counts.max(by: { $0.1 < $1.1 }) {
            return (value, count)
        }
        return nil
    }
    private func requestTelemetry(peripheral: CBPeripheral, characteristic: CBCharacteristic, writeType: CBCharacteristicWriteType) {
        switch telemetryType {
        case .unknown:
            break
        case .custom:
            break
        case .smartPort:
            break
        case .mavLink_v1:
            break
        case .mavLink_v2:
            break
        case .msp:
            peripheral.writeValue(msp.request(messageID: .MSP_STATUS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_RAW_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_COMP_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_ATTITUDE), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_ANALOG), for: characteristic, type: writeType)
        }
    }
    private func mspRequest(requesting: Bool){
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
        
        if requesting {
            timerRequestMSP = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [self] _ in
                if let manager = self.bluetoothManager,
                   let writeChars = manager.writeCharacteristic,
                   let peripheral = manager.connectedPeripheral {
                    requestTelemetry(peripheral: peripheral,
                                     characteristic: writeChars,
                                     writeType: manager.writeTypeCharacteristic)
                }
            }
        }
    }
}
