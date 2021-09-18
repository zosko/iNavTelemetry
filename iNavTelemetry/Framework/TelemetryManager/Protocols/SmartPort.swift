//
//  SmartPort.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/2/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI

class SmartPort: NSObject {
    
    enum State : Int {
        case IDLE = 0
        case DATA = 1
        case XOR = 2
    }
    
    private let PACKET_SIZE : UInt8 = 0x09
    private let START_BYTE : UInt8 = 0x7E
    private let DATA_START : UInt8 = 0x10
    private let DATA_STUFF : UInt8 = 0x7D
    private let STUFF_MASK : UInt8 = 0x20
    
    private let VFAS_SENSOR : UInt16 = 0x0210
    private let CELL_SENSOR : UInt16 = 0x0910
    private let VSPEED_SENSOR : UInt16 = 0x0110
    private let GSPEED_SENSOR : UInt16 = 0x0830
    private let ALT_SENSOR : UInt16 = 0x0100
    private let GALT_SENSOR : UInt16 = 0x0820
    private let DISTANCE_SENSOR : UInt16 = 0x0420
    private let FUEL_SENSOR : UInt16 = 0x0600
    private let GPS_SENSOR : UInt16 = 0x0800
    private let CURRENT_SENSOR : UInt16 = 0x200
    private let HEADING_SENSOR : UInt16 = 0x0840
    private let RSSI_SENSOR : UInt16 = 0xF101
    private let FLYMODE_SENSOR : UInt16 = 0x0400
    private let GPS_STATE_SENSOR : UInt16 = 0x0410
    private let PITCH_SENSOR : UInt16 = 0x0430
    private let ROLL_SENSOR : UInt16 = 0x0440
    private let AIRSPEED_SENSOR : UInt16 = 0x0A00
    private let FLIGHT_PATH_VECTOR : UInt16 = 0x0450
    private let RX_BAT : UInt16 = 0xF104
    
    private var state : State = .IDLE
    private var bufferIndex : Int = 0
    private var buffer : [UInt8] = [UInt8](repeating: 0, count: 9)
    private var newLatitude = false
    private var newLongitude = false
    private var latitude : Double = 0.0
    private var longitude : Double = 0.0
    var packet = TelemetryManager.Packet()
    
    //MARK: Helpers
    private func buffer_get_int16(buffer: [UInt8], index : Int) -> UInt16{
        return UInt16(buffer[index]) << 8 | UInt16(buffer[index - 1])
    }
    private func buffer_get_int32(buffer: [UInt8], index : Int) -> Int32 {
        return Int32(buffer[index]) << 24 | Int32(buffer[index - 1]) << 16 | Int32(buffer[index - 2]) << 8 | Int32(buffer[index - 3])
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
                    case GSPEED_SENSOR:
                        packet.speed = Int((Double(rawData) / (1944.0 / 100.0)) / 27.778)
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
                        if (Int(rawData) & Int(0x80000000) == 0) {
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
                        packet.pitch = -pitch
                        break
                    case ROLL_SENSOR:
                        let roll = Int(Double(rawData) / 10.0)
                        packet.roll = roll
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
