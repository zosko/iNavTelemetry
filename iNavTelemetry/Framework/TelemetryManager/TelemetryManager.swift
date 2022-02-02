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
            if custom.process(incomingData) {
                packet = custom.packet
                return true
            }
            return false
        case .smartPort:
            if smartPort.process(incomingData) {
                packet = smartPort.packet
                return true
            }
            return false
        case .msp:
            if msp.process(incomingData) {
                packet = msp.packet
                return true
            }
            return false
        case .mavLink_v1:
            if mavLink_v1.process(incomingData) {
                packet = mavLink_v1.packet
                return true
            }
            return false
        case .mavLink_v2:
            if mavLink_v2.process(incomingData) {
                packet = mavLink_v2.packet
                return true
            }
            return false
        }
    }

    // MARK: - Private functions
    private func detectProtocol(incomingData: Data) -> [TelemetryType] {
        var receivedUnknown = true
        requestMSPTelemetry()
        
        if custom.process(incomingData) {
            if custom.packet.rssi != 0 { protocolDetector.append(.custom) }
            receivedUnknown = false
        }
        if smartPort.process(incomingData) {
            if smartPort.packet.rssi != 0 { protocolDetector.append(.smartPort) }
            receivedUnknown = false
        }
        if msp.process(incomingData) {
            if msp.packet.flight_mode != 0 { protocolDetector.append(.msp) }
            receivedUnknown = false
        }
        if mavLink_v1.process(incomingData) {
            if mavLink_v1.packet.rssi != 0 { protocolDetector.append(.mavLink_v1) }
            receivedUnknown = false
        }
        if mavLink_v2.process(incomingData) {
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
    private func requestMSPTelemetry() {
        guard let manager = self.bluetoothManager else {
            print("Bluetooth Manager error")
            return
        }
        manager.write(msp.request(messageID: .MSP_STATUS))
        manager.write(msp.request(messageID: .MSP_RAW_GPS))
        manager.write(msp.request(messageID: .MSP_COMP_GPS))
        manager.write(msp.request(messageID: .MSP_ATTITUDE))
        manager.write(msp.request(messageID: .MSP_ANALOG))
    }
    private func mspRequest(requesting: Bool) {
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
        
        if requesting {
            timerRequestMSP = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [self] _ in
                requestMSPTelemetry()
            }
        }
    }
}
