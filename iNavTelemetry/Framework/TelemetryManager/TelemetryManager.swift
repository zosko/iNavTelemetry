//
//  Telemetry.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/31/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//
import Foundation
import CoreBluetooth

final class TelemetryManager: ObservableObject {
    
    @Published private(set) var telemetry: InstrumentTelemetry = InstrumentTelemetry(packet: Packet(), telemetryType: .unknown)
    @Published private(set) var telemetryType: TelemetryType = .unknown
    
    private let smartPort = SmartPort()
    private let custom = Custom()
    private let msp = MSP_V1()
    private let mavLink_v1 = MavLink_v1()
    private let mavLink_v2 = MavLink_v2()
    private var protocolDetector: [TelemetryType] = []
    private var timerRequestMSP: Timer?
    private var bluetoothManager: BluetoothManager?
    private var packet = Packet() {
        didSet {
            telemetry = InstrumentTelemetry(packet: packet, telemetryType: telemetryType)
        }
    }
    
    // MARK: - Internal functions
    func stopTelemetry() {
        self.telemetryType = .unknown
        self.protocolDetector = []
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
    }
    func addBluetoothManager(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
    }
    func parse(incomingData: Data) -> Bool {
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

    // MARK: - Private functions
    private func detectProtocol(incomingData: Data) -> [TelemetryType] {
        var receivedUnknown = true
        if let manager = self.bluetoothManager,
           let writeChars = manager.writeCharacteristic,
           let peripheral = manager.peripheral {
            peripheral.writeValue(msp.request(messageID: .MSP_STATUS),
                                  for: writeChars,
                                  type: manager.writeTypeCharacteristic)
        }
        
        if custom.process_incoming_bytes(incomingData: incomingData) {
            if custom.packet.rssi != 0 { protocolDetector.append(.custom) }
            receivedUnknown = false
        }
        if smartPort.process_incoming_bytes(incomingData: incomingData) {
            if smartPort.packet.rssi != 0 { protocolDetector.append(.smartPort) }
            receivedUnknown = false
        }
        if msp.process_incoming_bytes(incomingData: incomingData) {
            if msp.packet.flight_mode != 0 { protocolDetector.append(.msp) }
            receivedUnknown = false
        }
        if mavLink_v1.process_incoming_bytes(incomingData: incomingData) {
            if mavLink_v1.packet.rssi != 0 { protocolDetector.append(.mavLink_v1) }
            receivedUnknown = false
        }
        if mavLink_v2.process_incoming_bytes(incomingData: incomingData) {
            if mavLink_v2.packet.rssi != 0 { protocolDetector.append(.mavLink_v2) }
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
        case .unknown, .custom, .smartPort, .mavLink_v1, .mavLink_v2:
            break
        case .msp:
            peripheral.writeValue(msp.request(messageID: .MSP_STATUS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_RAW_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_COMP_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_ATTITUDE), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_ANALOG), for: characteristic, type: writeType)
        }
    }
    private func mspRequest(requesting: Bool) {
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
        
        if requesting {
            timerRequestMSP = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [self] _ in
                if let manager = self.bluetoothManager,
                   let writeChars = manager.writeCharacteristic,
                   let peripheral = manager.peripheral {
                    requestTelemetry(peripheral: peripheral,
                                     characteristic: writeChars,
                                     writeType: manager.writeTypeCharacteristic)
                }
            }
        }
    }
}
