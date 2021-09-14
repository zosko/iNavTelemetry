//
//  MSP.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/25/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import SwiftUI

class MSP_V1: NSObject {
    
    enum MSP_Request_Replies: UInt8 {
        case MSP_STATUS                 = 101
        case MSP_RAW_GPS                = 106
        case MSP_COMP_GPS               = 107
        case MSP_ATTITUDE               = 108
        case MSP_ANALOG                 = 110
    }

    struct msp_raw_gps {
        let fix: UInt8 /* bool */
        let num_sat: UInt8
        let coord_lat: Int32 /* 1 / 10 000 000 deg */
        let coord_lon: Int32 /* 1 / 10 000 000 deg */
        let altitude: Int16 /* m */
        let speed: Int16 /* cm/s */
        let ground_course: Int16 /* deg * 10 */
        let hdop: UInt16
    }

    struct msp_comp_gps {
        let distance_to_home: Int16
        let direction_to_home: Int16 /* [-180:180] deg */
        let update: UInt8
    }

    struct msp_attitude {
        let angx: Int16 /* [-1800:1800] 1/10 deg */
        let angy: Int16 /* [-900:900] 1/10 deg */
        let heading: Int16 /* [-180:180] deg */
    }

    struct msp_analog {
        let vbat: UInt8 /* 1/10 V */
        let power_meter_sum: UInt16
        let rssi: UInt16 /* [0:1023] */
        let amperage: Int16 // Current in 0.01A steps, range is -320A to 320A
    }

    struct msp_status {
      let cycle_time: UInt16 /* us */
      let i2c_errors_count: UInt16
      let sensor: UInt16
      let flag: UInt32
      let current_set: UInt8
    }
    
    var packet = TelemetryManager.Packet()
    
    func request(messageID: MSP_Request_Replies) -> Data{
        var buffer : [UInt8] = [UInt8](repeating: 0, count: 6)
        buffer[0] = 36 // "$"
        buffer[1] = 77 // "M"
        buffer[2] = 60 // "<"
        buffer[3] = 0
        buffer[4] = messageID.rawValue
        buffer[5] = 0 ^ messageID.rawValue
        
        return Data(bytes: buffer, count: buffer.count)
    }
    func process_incoming_bytes(incomingData: Data) -> Bool {
        let bytes: [UInt8] = incomingData.map{ $0 }
        
        guard bytes.count > 4 else { return false }
        
        let h1 = 36 // "$"
        let h2 = 77 // "M"
        let h3 = 62 // ">"
        
        // check header
        if bytes[0] == h1 && bytes[1] == h2 && bytes[2] == h3 {
            // header ok, read payload size
            let recvSize = bytes[3]
            let messageID = bytes[4]
            
            var checksumCalc = recvSize ^ messageID

            var payload: [UInt8] = []
                        
            // read payload
            var idx = 5 // start from byte 5
            while (idx < bytes.count - 1) {
                let b: UInt8 = bytes[idx]
                checksumCalc ^= b
                payload.append(b)
                idx += 1
            }
            
            //let compGPS = dataToStruct(buffer: payload, structType: msp_comp_gps.self)
            
            switch MSP_Request_Replies(rawValue: messageID) {
            case .MSP_ATTITUDE:
                packet.roll = Int(buffer_get_int16(buffer: payload, index: 1)) / 10
                packet.pitch = Int(buffer_get_int16(buffer: payload, index: 3)) / 10
                packet.heading = Int(buffer_get_int16(buffer: payload, index: 5))
            case .MSP_RAW_GPS:
                packet.gps_sats = Int(payload[1])
                packet.lat = Double(buffer_get_int32(buffer: payload, index: 5)) / 10000000
                packet.lng = Double(buffer_get_int32(buffer: payload, index: 9)) / 10000000
                packet.alt = Int(buffer_get_int16(buffer: payload, index: 11))
                packet.speed = Int(Double(buffer_get_int16(buffer: payload, index: 13)) * 0.036)
            case .MSP_ANALOG:
                packet.voltage = Double(payload[0]) / 10
                packet.rssi = Int(buffer_get_int16(buffer: payload, index: 4)) / 10
                packet.current = Int(buffer_get_int16(buffer: payload, index: 6)) / 100
            case .MSP_COMP_GPS:
                packet.distance = Int(buffer_get_int16(buffer: payload, index: 1))
            case .MSP_STATUS:
                packet.flight_mode = Int(buffer_get_int32(buffer: payload, index: 9))
            default:
                print("cant decode")
                break
            }
            
            // read and check checksum
            let checksum: UInt8 = bytes[idx]
            if checksumCalc == checksum {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    private func dataToStruct<T>(buffer: [UInt8], structType: T.Type) -> T {
        let dataPayload = Data(bytes: buffer, count: buffer.count)
        let converted:T = dataPayload.withUnsafeBytes { $0.load(as: structType.self) }
        return converted
    }
    
    private func buffer_get_int16(buffer: [UInt8], index : Int) -> Int16{
        return Int16(buffer[index]) << 8 | Int16(buffer[index - 1])
    }
    
    private func buffer_get_int32(buffer: [UInt8], index : Int) -> Int32 {
        return Int32(buffer[index]) << 24 | Int32(buffer[index - 1]) << 16 | Int32(buffer[index - 2]) << 8 | Int32(buffer[index - 3])
    }
}
