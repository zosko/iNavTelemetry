//
//  Telemetry.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/31/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

#if os(OSX)
    import Cocoa
    import ORSSerial
    import CoreBluetooth
#else
    import UIKit
    import CoreBluetooth
#endif

enum TelemetryType: Int {
    case SMARTPORT = 0
    case MSP = 1
    case CUSTOM = 2
}

enum BluetoothType : Int {
    case HM_10 = 0
    case FRSKY_BUILT_IN = 1
}

enum BluetoothUUID : String {
    case HM10_SERVICE = "FFE0"
    case HM10_CHAR = "FFE1" //write
    case FRSKY_SERVICE = "FFF0"
    case FRSKY_CHAR = "FFF6" //write
}

struct TelemetryStruct : Codable {
    var lat = 0.0
    var lng = 0.0
    var alt = 0
    var gps_sats = 0
    var distance = 0
    var speed = 0
    var voltage = 0.0
    var rssi = 0
    var current = 0
    var heading = 0
    var flight_mode = 0
    var fuel = 0
    var roll = 0
    var pitch = 0
    
    init(){
        
    }
}

class Telemetry: NSObject {
    
    private var telemetryType: TelemetryType = .SMARTPORT
    private var telemetry = TelemetryStruct()
    
    private var smartPort = SmartPort()
    private var custom = CustomTelemetry()
    private var msp = MSP()
    private var bluetoothType: BluetoothType = .FRSKY_BUILT_IN
    
    func chooseTelemetry(type: TelemetryType){
        self.telemetryType = type
    }
    
    func getTelemetryType() -> TelemetryType {
        return self.telemetryType
    }
    
    func getTelemetry() -> TelemetryStruct {
        return telemetry
    }
    
    #if os(OSX)
    func requestTelemetry(serialPort: ORSSerialPort) {
        switch telemetryType {
        case .CUSTOM:
            break
        case .SMARTPORT:
            break
        case .MSP:
            serialPort.send(msp.request(messageID: .MSP_MSG_STATUS))
            serialPort.send(msp.request(messageID: .MSP_MSG_RAW_GPS))
            serialPort.send(msp.request(messageID: .MSP_MSG_COMP_GPS))
            serialPort.send(msp.request(messageID: .MSP_MSG_ATTITUDE))
            serialPort.send(msp.request(messageID: .MSP_MSG_ANALOG))
        }
    }
    #endif
    
    func requestTelemetry(peripheral: CBPeripheral, characteristic: CBCharacteristic, writeType: CBCharacteristicWriteType) {
        switch telemetryType {
        case .CUSTOM:
            break
        case .SMARTPORT:
            break
        case .MSP:
            peripheral.writeValue(msp.request(messageID: .MSP_MSG_STATUS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_MSG_RAW_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_MSG_COMP_GPS), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_MSG_ATTITUDE), for: characteristic, type: writeType)
            peripheral.writeValue(msp.request(messageID: .MSP_MSG_ANALOG), for: characteristic, type: writeType)
        }
    }
    
    func parse(incomingData: Data) -> Bool{
        switch telemetryType {
        case .CUSTOM:
            if custom.process_incoming_bytes(incomingData: incomingData) {
                telemetry = custom.packet
                return true
            }
            return false
        case .SMARTPORT:
            if smartPort.process_incoming_bytes(incomingData: incomingData) {
                telemetry = smartPort.packet
                return true
            }
            return false
        case .MSP:
            if msp.process_incoming_bytes(incomingData: incomingData) {
                telemetry = msp.packet
                return true
            }
            return false
        }
    }
    
    //MARK: Functions
    func getStabilization() -> String{
        if telemetryType == .SMARTPORT {
            let mode = telemetry.flight_mode / 10 % 10
            if mode == 2{
                return "horizon"
            }
            else if mode == 1 {
                return "angle"
            }
            else{
                return "manual"
            }
        }
        else{
            return "N/A"
        }
        
    }
    func getArmed() -> String{
        if telemetryType == .SMARTPORT {
            let mode = telemetry.flight_mode % 10
            if mode == 5{
                return "YES"
            }
            return "NO"
        }
        else{
            return "N/A"
        }
    }
}
