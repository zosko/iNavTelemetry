//
//  SmartPort.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/2/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit

struct SmartPortStruct : Codable {
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

enum State : Int {
    case IDLE = 0
    case DATA = 1
    case XOR = 2
}

class SmartPort: NSObject {
    let PACKET_SIZE : UInt8 = 0x09
    let START_BYTE : UInt8 = 0x7E
    let DATA_START : UInt8 = 0x10
    let DATA_STUFF : UInt8 = 0x7D
    let STUFF_MASK : UInt8 = 0x20
    
    let VFAS_SENSOR : UInt16 = 0x0210
    let CELL_SENSOR : UInt16 = 0x0910
    let VSPEED_SENSOR : UInt16 = 0x0110
    let GSPEED_SENSOR : UInt16 = 0x0830
    let ALT_SENSOR : UInt16 = 0x0100
    let GALT_SENSOR : UInt16 = 0x0820
    let DISTANCE_SENSOR : UInt16 = 0x0420
    let FUEL_SENSOR : UInt16 = 0x0600
    let GPS_SENSOR : UInt16 = 0x0800
    let CURRENT_SENSOR : UInt16 = 0x200
    let HEADING_SENSOR : UInt16 = 0x0840
    let RSSI_SENSOR : UInt16 = 0xF101
    let FLYMODE_SENSOR : UInt16 = 0x0400
    let GPS_STATE_SENSOR : UInt16 = 0x0410
    let PITCH_SENSOR : UInt16 = 0x0430
    let ROLL_SENSOR : UInt16 = 0x0440
    let AIRSPEED_SENSOR : UInt16 = 0x0A00
    let FLIGHT_PATH_VECTOR : UInt16 = 0x0450
    let RX_BAT : UInt16 = 0xF104
    
    var state : State = .IDLE
    var bufferIndex : Int = 0
    var buffer : [UInt8] = [UInt8](repeating: 0, count: 9)
    var newLatitude = false
    var newLongitude = false
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var packet = SmartPortStruct()
    
    //MARK: Functions
    func getStabilization() -> String{
        let mode = packet.flight_mode / 10 % 10
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
    func getArmed() -> String{
        let mode = packet.flight_mode % 10
        if mode == 5{
            return "YES"
        }
        return "NO"
    }
    
    //MARK: Helpers
    func buffer_get_int16(buffer: [UInt8], index : Int) -> UInt16{
        return UInt16(buffer[index]) << 8 | UInt16(buffer[index - 1])
    }
    func buffer_get_int32(buffer: [UInt8], index : Int) -> Int32 {
        return Int32(buffer[index]) << 24 | Int32(buffer[index - 1]) << 16 | Int32(buffer[index - 2]) << 8 | Int32(buffer[index - 3])
    }
    func linearInterpolation(inVal:Double, inMin:Double, inMax:Double, outMin:Double, outMax:Double) -> Double{
        if (inMin == 0 && inMax == 0) {
            return 0.0;
        }
        return (inVal - inMin) / (inMax - inMin) * (outMax - outMin) + outMin;
    }
    
    //MARK: Telemetry functions
    func process_incoming_bytes(incomingData: Data) -> Bool{
        let data: [UInt8] = incomingData.map{ $0 }
        
        for i in 0 ..< data.count {
            switch state {
            case .IDLE:
                if data[i] == START_BYTE {
                    state = .DATA
                    bufferIndex = 0
                }
                break
            case .DATA:
                if data[i] == DATA_STUFF {
                    state = .XOR
                }
                else if data[i] == START_BYTE {
                    bufferIndex = 0
                }
                else{
                    buffer[bufferIndex] = data[i]
                    bufferIndex += 1
                }
                break
            case .XOR:
                buffer[bufferIndex] = data[i] ^ STUFF_MASK
                bufferIndex += 1
                state = .DATA
                break
            }
            
            if bufferIndex == PACKET_SIZE {
                state = .IDLE
                
                _ = buffer[0] //sensor type
                let packetType = buffer[1]
                if packetType == DATA_START {
                    let dataType = buffer_get_int16(buffer: buffer, index:3)
                    let rawData = buffer_get_int32(buffer: buffer, index:7)
                    
                    switch dataType {
                    case VFAS_SENSOR:
                        packet.voltage = Double(rawData) / 100.0
                        break
                    case CELL_SENSOR:
                        let cell = Double(rawData) / 100.0
                        print("CELL: \(cell)")
                        break
                    case VSPEED_SENSOR:
                        let vspeed = Double(rawData) / 100.0
                        print("VSPEED_SENSOR  vspeed:\(vspeed)")
                        break
                    case GSPEED_SENSOR:
                        packet.speed = Int((Double(rawData) / (1944.0 / 100.0)) / 27.778)
                        break
                    case ALT_SENSOR:
                        let alt = Double(rawData) / 100.0
                        print("ALT_SENSOR  alt:\(alt)")
                        break
                    case GALT_SENSOR:
                        packet.alt = Int(Double(rawData) / 100.0)
                        break
                    case DISTANCE_SENSOR:
                        packet.distance = Int(rawData)
                        break
                    case FUEL_SENSOR:
                        packet.fuel = Int(rawData)
                        break
                    case GPS_SENSOR:
                        var gpsData = Double((rawData & 0x3FFFFFFF)) / 10000.0 / 60.0
                        if (rawData & 0x40000000 > 0) {
                            gpsData = -gpsData
                        }
                        let bigNumber:UInt32 = 0x80000000
                        if (Int(rawData) & Int(bigNumber) == 0) {
                            newLatitude = true
                            latitude = gpsData
                        } else {
                            newLongitude = true
                            longitude = gpsData
                        }
                        if (newLatitude && newLongitude) {
                            newLongitude = false
                            newLatitude = false
                            packet.lat = latitude
                            packet.lng = longitude
                        }
                        break
                    case CURRENT_SENSOR:
                        packet.current = Int(Double(rawData) / 10.0)
                        break
                    case HEADING_SENSOR:
                        packet.heading = Int(Double(rawData) / 100.0)
                        break
                    case RSSI_SENSOR:
                        packet.rssi = Int(rawData)
                        break
                    case FLYMODE_SENSOR:
                        packet.flight_mode = Int(rawData)
                        break
                    case GPS_STATE_SENSOR:
                        packet.gps_sats = Int(rawData % 100)
                        break
                    case PITCH_SENSOR:
                        let pitch = Int(Double(rawData) / 10.0)
                        packet.pitch = pitch
                        break
                    case ROLL_SENSOR:
                        let roll = Int(Double(rawData) / 10.0)
                        packet.roll = roll
                        break
                    case AIRSPEED_SENSOR:
                        print("AIRSPEED_SENSOR")
                        break
                    case FLIGHT_PATH_VECTOR:
                        print("FLIGHT_PATH_VECTOR")
                        break
                    case RX_BAT:
                        print("RX_BAT")
                        break
                    default:
                        print("dataType: \(String(format:"%02X", dataType))  rawData: \(rawData) buffer \(String(format:"%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X", buffer[0],buffer[1],buffer[2],buffer[3],buffer[4],buffer[5],buffer[6],buffer[7],buffer[8]))")
                        break
                    }
                    return true
                }
            }
        }
        return false
    }
}
