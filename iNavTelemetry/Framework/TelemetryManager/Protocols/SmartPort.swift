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
    private let FSSP_DATAID_ADC2 : UInt16 = 0xF103
    private let PGR_PGN_VERSION_MASK: UInt16 = 0xF000
    private let UNKNOWN_PACKET_1 : UInt16 = 0xF105
    
    // QCZEK LRS
    private let APID_GPS_COURSE : UInt16 = 0x0840
    private let APID_RSSI : UInt16 = 0xF101
    private let APID_VFAS : UInt16 = 0x0210
    private let APID_CURRENT : UInt16 = 0x0200
    private let APID_CELLS : UInt16 = 0x0300
    private let APID_ALTITUDE : UInt16 = 0x0100
    private let APID_VARIO : UInt16 = 0x0110
    private let APID_GPS_SPEED : UInt16 = 0x0830
    private let APID_LATLONG : UInt16 = 0x0800
    private let APID_GPS_ALTITUDE : UInt16 = 0x0820
    private let APID_AIR_SPEED : UInt16 = 0x0a00
    private let APID_FUEL : UInt16 = 0x0600
    private let APID_T1 : UInt16 = 0x0400
    private let APID_T2 : UInt16 = 0x0410
    private let APID_PITCH : UInt16 = 0x0430
    private let APID_ROLL : UInt16 = 0x0440
    private let APID_MAV_BASE_MODE : UInt16 = 0x04A0
    private let APID_MAV_SYS_STATUS : UInt16 = 0x04A1
    private let APID_MAV_CUSTOM_MODE : UInt16 = 0x04A2
    private let APID_CUST_RSSI : UInt16 = 0x04B0
    private let APID_RX_RSSI_REG_VAL : UInt16 = 0x04B1 // with offset 157 for 868MHz and 146 for 433MHz
    private let APID_RX_SNR_REG_VAL : UInt16 = 0x04B2 // with offset 64.
    private let APID_RX_PACKET_LOST_VAL : UInt16 = 0x04B3
    
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
        var isProcessed = false
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
                    case VFAS_SENSOR, APID_VFAS:
                        packet.voltage = Double(rawData) / 100.0
                        packet.valid += 1
                        isProcessed = true
                        break
                    case GSPEED_SENSOR, APID_GPS_SPEED:
                        packet.speed = Int((Double(rawData) / (1944.0 / 100.0)) / 27.778)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case GALT_SENSOR, APID_GPS_ALTITUDE:
                        packet.alt = Int(Double(rawData) / 100.0)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case DISTANCE_SENSOR:
                        packet.distance = Int(rawData)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case FUEL_SENSOR, APID_FUEL:
                        packet.fuel = Int(rawData)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case GPS_SENSOR, APID_LATLONG:
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
                        packet.valid += 1
                        isProcessed = true
                        break
                    case CURRENT_SENSOR, APID_CURRENT:
                        packet.current = Int(Double(rawData) / 10.0)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case HEADING_SENSOR, APID_GPS_COURSE:
                        packet.heading = Int(Double(rawData) / 100.0)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case RSSI_SENSOR, APID_RSSI:
                        packet.rssi = Int(rawData)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case FLYMODE_SENSOR, APID_T1:
                        packet.flight_mode = Int(rawData)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case GPS_STATE_SENSOR, APID_T2:
                        packet.gps_sats = Int(rawData % 100)
                        packet.valid += 1
                        isProcessed = true
                        break
                    case PITCH_SENSOR, APID_PITCH:
                        let pitch = Int(Double(rawData) / 10.0)
                        packet.pitch = -pitch
                        packet.valid += 1
                        isProcessed = true
                        break
                    case ROLL_SENSOR, APID_ROLL:
                        let roll = Int(Double(rawData) / 10.0)
                        packet.roll = roll
                        packet.valid += 1
                        isProcessed = true
                        break
                    default:
                        packet.unknown += 1
                        print("type: \(String(format:"%02X", dataType))  data: \(rawData) buffer \(String(format:"%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X", buffer[0],buffer[1],buffer[2],buffer[3],buffer[4],buffer[5],buffer[6],buffer[7],buffer[8]))")
                        isProcessed = false
                        break
                    }
                }
            }
        }
        return isProcessed
    }
}
