//
//  MSP.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 7/25/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import Foundation

enum MSP_Request_Replies: Int16 {
    case MSP_MSG_IDENT                  = 100
    case MSP_MSG_STATUS                 = 101
    case MSP_MSG_RAW_GPS                = 106
    case MSP_MSG_COMP_GPS               = 107
    case MSP_MSG_ATTITUDE               = 108
    case MSP_MSG_ANALOG                 = 110
}

struct msp_ident {
    let version: UInt8
    let multitype: UInt8
    let msp_version: UInt8
    let capability: UInt32
}

struct msp_raw_gps {
    let fix: UInt8 /* bool */
    let num_sat: UInt8
    let coord_lat: UInt32 /* 1 / 10 000 000 deg */
    let coord_lon: UInt32 /* 1 / 10 000 000 deg */
    let altitude: UInt16 /* m */
    let speed: UInt16 /* cm/s */
    let ground_course: UInt16 /* deg * 10 */
}

struct msp_comp_gps {
    let distance_to_home: UInt16
    let direction_to_home: UInt16 /* [-180:180] deg */
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
    let amperage: UInt16
}

struct msp_status {
  let cycle_time: UInt16 /* us */
  let i2c_errors_count: UInt16
  let sensor: UInt16
  let flag: UInt32
  let current_set: UInt8
}

struct MSPStruct : Codable {
    var lat = 0.0 //
    var lng = 0.0 //
    var alt = 0 //
    var gps_sats = 0 //
    var distance = 0 //
    var speed = 0 //
    var voltage = 0.0 //
    var rssi = 0 //
    var current = 0 //
    var heading = 0 //
    var flight_mode = 0
    var fuel = 0
    var roll = 0 //
    var pitch = 0 //
    
    init(){
        
    }
}

class MSP: NSObject {
    
    var packet = MSPStruct()
    
    func request(messageID: MSP_Request_Replies, payload: [UInt8] = [], size: UInt16 = 0) -> Data{
        let flag: UInt8 = 0
        var msg_size: Int = 9
        var crc: UInt8 = 0
        var tmp_buf: [UInt8] = [UInt8](repeating: 0, count: 2)
        
        msg_size += Int(size)
        
        var buffer : [UInt8] = [UInt8](repeating: 0, count: payload.count + msg_size)
        buffer[0] = 36 // "$"
        buffer[1] = 88 // "X"
        buffer[2] = 60 // "<"
        
        crc = crc8_dvb_s2(crc: crc, a: flag)
        buffer[3] = crc
        
        tmp_buf[0] = UInt8(messageID.rawValue & 0xff)
        tmp_buf[1] = UInt8((messageID.rawValue >> 8) & 0xff)
        
        crc = crc8_dvb_s2(crc: crc, a: tmp_buf[0])
        crc = crc8_dvb_s2(crc: crc, a: tmp_buf[1])
        
        buffer[4] = tmp_buf[0]
        buffer[5] = tmp_buf[1]
        
        tmp_buf[0] = UInt8(size & 0xff)
        tmp_buf[1] = UInt8((size >> 8) & 0xff)
        
        crc = crc8_dvb_s2(crc: crc, a: tmp_buf[0])
        crc = crc8_dvb_s2(crc: crc, a: tmp_buf[1])
        
        buffer[6] = tmp_buf[0]
        buffer[7] = tmp_buf[1]
        
        var buffCount = 8
        payload.forEach { b in
            crc = crc8_dvb_s2(crc: crc, a: b)
            buffer[buffCount] = b
            buffCount += 1
        }
        buffer[buffCount] = crc
        
        return Data(bytes: buffer, count: buffer.count)
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
    
    private func crc8_dvb_s2(crc: UInt8, a: UInt8) -> UInt8 {
        var newCRC = crc
        newCRC ^= a
        
        for _ in 0 ..< 8 {
            if ((newCRC & 0x80) != 0) {
                newCRC = (newCRC << 1) ^ 0xD5;
            } else {
                newCRC = newCRC << 1;
            }
        }
        
        return newCRC
    }
    
    func process_incoming_bytes(incomingData: Data) -> Bool {
        guard incomingData.count > 8 else { return false }
        
        let bytes: [UInt8] = incomingData.map{ $0 }
        
        let h1 = 36 // "$"
        let h2 = 88 // "X"
        let h3 = 62 // ">"
        
        // check header
        if bytes[0] == h1 && bytes[1] == h2 && bytes[2] == h3 {
            // header ok, read payload size
            var tmp_buf: [UInt8] = [UInt8](repeating: 0, count: 2)
            
            let flag = bytes[3]
            let messageID: Int16 = buffer_get_int16(buffer: bytes, index: 5)
            
            var checksumCalc: UInt8 = 0
            checksumCalc = crc8_dvb_s2(crc: checksumCalc, a: flag)
            
            tmp_buf[0] = UInt8(messageID & 0xff)
            tmp_buf[1] = UInt8((messageID >> 8) & 0xff)
            
            checksumCalc = crc8_dvb_s2(crc: checksumCalc, a: tmp_buf[0])
            checksumCalc = crc8_dvb_s2(crc: checksumCalc, a: tmp_buf[1])
            
            let recvSize = buffer_get_int16(buffer: bytes, index: 7)
            
            tmp_buf[0] = UInt8(recvSize & 0xff)
            tmp_buf[1] = UInt8((recvSize >> 8) & 0xff)
            
            checksumCalc = crc8_dvb_s2(crc: checksumCalc, a: tmp_buf[0])
            checksumCalc = crc8_dvb_s2(crc: checksumCalc, a: tmp_buf[1])
            
            var payload: [UInt8] = [UInt8](repeating: 0, count: Int(recvSize+2)) // needs 2 bytes to prevent crash on struct
                        
            // read payload
            var idx = 8 // start from byte 8
            var idTmp = 0
            while (idx < bytes.count - 1) {
                let b: UInt8 = bytes[idx]
                checksumCalc = crc8_dvb_s2(crc: checksumCalc, a: b)
                payload[idTmp] = b
                idx += 1
                idTmp += 1
            }
            
            switch MSP_Request_Replies(rawValue: messageID) {
            case .MSP_MSG_IDENT:
                let ident = dataToStruct(buffer: payload, structType: msp_ident.self) // +1 bytes need in payload
                print(ident)
            case .MSP_MSG_ATTITUDE:
                let attitude = dataToStruct(buffer: payload, structType: msp_attitude.self)
                print(attitude)
                packet.roll = Int(buffer_get_int16(buffer: payload, index: 1)) / 10
                packet.pitch = Int(buffer_get_int16(buffer: payload, index: 3)) / 10
                packet.heading = Int(buffer_get_int16(buffer: payload, index: 5))
            case .MSP_MSG_RAW_GPS:
                let rawGPS = dataToStruct(buffer: payload, structType: msp_raw_gps.self)
                print(rawGPS)
                packet.gps_sats = Int(payload[1])
                packet.lat = Double(buffer_get_int32(buffer: payload, index: 5)) / 10000000
                packet.lng = Double(buffer_get_int32(buffer: payload, index: 9)) / 10000000
                packet.alt = Int(buffer_get_int16(buffer: payload, index: 11))
                packet.speed = Int(buffer_get_int16(buffer: payload, index: 13))
            case .MSP_MSG_ANALOG:
                let analog = dataToStruct(buffer: payload, structType: msp_analog.self)
                print(analog)
                packet.voltage = Double(payload[0]) / 10
                packet.rssi = Int(buffer_get_int16(buffer: payload, index: 4))
                packet.current = Int(buffer_get_int16(buffer: payload, index: 6))
            case .MSP_MSG_COMP_GPS:
                let compGPS = dataToStruct(buffer: payload, structType: msp_comp_gps.self)
                print(compGPS)
                packet.distance = Int(buffer_get_int16(buffer: payload, index: 1))
            case .MSP_MSG_STATUS:
                let status = dataToStruct(buffer: payload, structType: msp_status.self) // +2 bytes need in payload
                print(status)
                packet.flight_mode = Int(buffer_get_int16(buffer: payload, index: 3))
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
}
