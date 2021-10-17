//
//  MavLink.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/9/21.
//

import SwiftUI
import CoreLocation

class CRCMAVLink: NSObject {
    
    let MAVLINK_MESSAGE_CRCS: [Int] = [50, 124, 137, 0, 237, 217, 104, 119, 0, 0, 0, 89, 0, 0, 0, 0, 0, 0, 0, 0, 214, 159, 220, 168, 24, 23, 170, 144, 67, 115, 39, 246, 185, 104, 237, 244, 222, 212, 9, 254, 230, 28, 28, 132, 221, 232, 11, 153, 41, 39, 78, 196, 0, 0, 15, 3, 0, 0, 0, 0, 0, 167, 183, 119, 191, 118, 148, 21, 0, 243, 124, 0, 0, 38, 20, 158, 152, 143, 0, 0, 0, 106, 49, 22, 143, 140, 5, 150, 0, 231, 183, 63, 54, 47, 0, 0, 0, 0, 0, 0, 175, 102, 158, 208, 56, 93, 138, 108, 32, 185, 84, 34, 174, 124, 237, 4, 76, 128, 56, 116, 134, 237, 203, 250, 87, 203, 220, 25, 226, 46, 29, 223, 85, 6, 229, 203, 1, 195, 109, 168, 181, 47, 72, 131, 127, 0, 103, 154, 178, 200, 134, 219, 208, 188, 84, 22, 19, 21, 134, 0, 78, 68, 189, 127, 154, 21, 21, 144, 1, 234, 73, 181, 22, 83, 167, 138, 234, 240, 47, 189, 52, 174, 229, 85, 159, 186, 72, 0, 0, 0, 0, 92, 36, 71, 98, 120, 0, 0, 0, 0, 134, 205, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 69, 101, 50, 202, 17, 162, 0, 0, 0, 0, 0, 0, 207, 0, 0, 0, 163, 105, 151, 35, 150, 0, 0, 0, 0, 0, 0, 90, 104, 85, 95, 130, 184, 81, 8, 204, 49, 170, 44, 83, 46, 0]
    private let CRC_INIT_VALUE = 0xffff
    private var crcValue: Int = 0
    
    override init(){
        super.init()
        
        self.start_checksum()
    }
    
    func update_checksum(_ dataIn: Int) {
        let data = dataIn & 0xff
        var tmp = data ^ (crcValue & 0xff)
        tmp ^= (tmp << 4) & 0xff
        crcValue = ((crcValue >> 8) & 0xff) ^ (tmp << 8) ^ (tmp << 3) ^ ((tmp >> 4) & 0xf)
    }
    func finish_checksum(_ msgid: Int) {
        if msgid >= 0 && msgid < MAVLINK_MESSAGE_CRCS.count {
            update_checksum(MAVLINK_MESSAGE_CRCS[msgid])
        }
    }
    func start_checksum() {
        crcValue = CRC_INIT_VALUE
    }
    func getMSB() -> Int {
        return ((crcValue >> 8) & 0xff)
    }
    func getLSB() -> Int {
        return (crcValue & 0xff)
    }

}

class MavLink: NSObject {
    
    private var crc = CRCMAVLink()
    private var state = State.IDLE
    private var buffer: [UInt8] = [UInt8](repeating: 0, count: 255)
    private var payloadIndex = 0
    private var packetLength: UInt8 = 0
    private var packetIncompatibility: UInt8 = 0
    private var packetCompatibility: UInt8 = 0
    private var packetIndex: UInt8 = 0
    private var systemId: UInt8 = 0
    private var componentId: UInt8 = 0
    private var messageId = 0
    private var messageIdBuffer : [UInt8] = [UInt8](repeating: 0, count: 4)
    private var messageIdIndex = 0
    private var crcLow: UInt8 = 0
    private var crcHigh: UInt8 = 0
    private var gotRadioStatus = false;  //preffer RADIO_STATUS messages over RC_CHANNELS_RAW

    enum State : Int {
        case IDLE = 0
        case LENGTH = 1
        case INCOMPATIBILITY = 2
        case COMPATIBILITY = 3
        case INDEX = 4
        case SYSTEM_ID = 5
        case COMPONENT_ID = 6
        case MESSAGE_ID = 7
        case PAYLOAD = 8
        case CRC = 9
    }
    
    private let PACKET_MARKER = 0xFD
    private let MAV_PACKET_HEARTBEAT_ID = 0
    private let MAV_PACKET_STATUS_ID = 1
    private let MAV_PACKET_ATTITUDE_ID = 30
    private let MAV_PACKET_RC_CHANNEL_ID = 35  //RC_CHANNELS_RAW
    private let MAV_PACKET_VFR_HUD_ID = 74
    private let MAV_PACKET_GPS_RAW_ID = 24
    private let MAV_PACKET_RADIO_STATUS_ID = 109
    private let MAV_PACKET_GPS_ORIGIN_ID = 49
    private let MAV_PACKET_STATUS_LENGTH = 31
    private let MAV_PACKET_HEARTBEAT_LENGTH = 9
    private let MAV_PACKET_RC_CHANNEL_LENGTH = 22
    private let MAV_PACKET_ATTITUDE_LENGTH = 28
    private let MAV_PACKET_VFR_HUD_LENGTH = 20
    private let MAV_PACKET_GPS_RAW_LENGTH = 30
    private let MAV_PACKET_RADIO_STATUS_LENGTH = 9
    
    var packet = TelemetryManager.Packet()
    var newLatitude = false
    var newLongitude = false
    var originLatitude = 0.0
    var originLongitude = 0.0
    var latitude = 0.0
    var longitude = 0.0
    
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
                if data[i] == PACKET_MARKER {
                    state = .LENGTH
                }
                break
            case .LENGTH:
                packetLength = data[i]
                state = .INCOMPATIBILITY
                break
            case .INCOMPATIBILITY:
                packetIncompatibility = data[i]
                state = .COMPATIBILITY
                break
            case .COMPATIBILITY:
                packetCompatibility = data[i]
                state = .INDEX
                break
            case .INDEX:
                packetIndex = data[i]
                state = .SYSTEM_ID
                break
            case .SYSTEM_ID:
                systemId = data[i]
                state = .COMPONENT_ID
                break
            case .COMPONENT_ID:
                componentId = data[i]
                state = .MESSAGE_ID
                messageIdIndex = 0
                break
            case .MESSAGE_ID:
                messageIdBuffer[messageIdIndex] = data[i]
                messageIdIndex += 1
                if (messageIdIndex >= 3) {
                    messageId = Int(buffer_get_int32(buffer: messageIdBuffer, index: 3))
                    state = .PAYLOAD
                    payloadIndex = 0
                    buffer = [UInt8](repeating: 0, count: Int(packetLength))
                }
                break
            case .PAYLOAD:
                if (payloadIndex < packetLength) {
                    buffer[payloadIndex] = data[i]
                    payloadIndex += 1
                } else {
                    state = .CRC
                    crcLow = data[i]
                    crcHigh = 0
                }
                break
            case .CRC:
                crcHigh = data[i]
                if checkCrc() {
                    processPacket()
                    isProcessed = true
                } else {
                    print("Bad CRC")
                }
                state = .IDLE
                break
            }
        }
        return isProcessed
    }
    
    private func processPacket() {
        if (messageId == MAV_PACKET_STATUS_ID) {
            packet.voltage = Double(buffer_get_int16(buffer: buffer, index: 13)) / 1000.0
            packet.current = Int(Double(buffer_get_int16(buffer: buffer, index: 15)) / 100.0)
            packet.fuel = Int(buffer[27])
        } else if (messageId == MAV_PACKET_HEARTBEAT_ID) {
            packet.flight_mode = Int(buffer[6])
        } else if (messageId == MAV_PACKET_RC_CHANNEL_ID) {
            let rssi = Int(buffer[20] & 0xff)
            if !gotRadioStatus {
                packet.rssi = rssi == 255 ? -1 : rssi * 100 / 254
            }
        } else if (messageId == MAV_PACKET_ATTITUDE_ID) {
            packet.roll = Int(buffer_get_int32(buffer: buffer, index: 7))
            packet.pitch = Int(buffer_get_int32(buffer: buffer, index: 11))
        } else if (messageId == MAV_PACKET_VFR_HUD_ID) {
            packet.speed = Int(Double(buffer_get_int32(buffer: buffer, index: 7)) * 100 / 100 * 3.6)
            packet.alt = Int(buffer_get_int32(buffer: buffer, index: 11)) * 100 / 100
        } else if (messageId == MAV_PACKET_RADIO_STATUS_ID) {
            let rssi = Int(buffer[3] & 0xff)
            packet.rssi = rssi == 255 ? -1 : rssi * 100 / 254
            gotRadioStatus = true
        } else if (messageId == MAV_PACKET_GPS_RAW_ID) {
            latitude = Double(buffer_get_int32(buffer: buffer, index: 7)) / 10000000
            longitude = Double(buffer_get_int32(buffer: buffer, index: 11)) / 10000000
            packet.heading = Int(buffer_get_int16(buffer: buffer, index: 21))
            packet.gps_sats = Int(buffer[22])
            
            newLatitude = true
            newLongitude = true
            
            self.gpsCoordinate()
            
        } else if (messageId == MAV_PACKET_GPS_ORIGIN_ID) {
            originLatitude = Double(buffer_get_int32(buffer: buffer, index: 3)) / 10000000
            originLongitude = Double(buffer_get_int32(buffer: buffer, index: 7)) / 10000000
            self.gpsCoordinate()
        } else {
            print("not parsed: \(messageId)")
            packet.unknown += 1
        }
    }
    
    private func gpsCoordinate(){
        if (originLatitude > 0 && originLongitude > 0 && latitude > 0 && longitude > 0) {
            let coordinate0 = CLLocation(latitude: originLatitude, longitude: originLongitude)
            let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
            packet.distance = Int(coordinate0.distance(from: coordinate1))
        }
        
        if (newLatitude && newLongitude) {
            packet.lat = latitude
            packet.lng = longitude
            
            newLatitude = false
            newLongitude = false
        }
    }
    
    private func checkCrc() -> Bool {
        crc.start_checksum()
        crc.update_checksum(Int(packetLength))
        crc.update_checksum(Int(packetIncompatibility))
        crc.update_checksum(Int(packetCompatibility))
        crc.update_checksum(Int(packetIndex))
        crc.update_checksum(Int(systemId))
        crc.update_checksum(Int(componentId))
        messageIdBuffer.forEach {
            crc.update_checksum(Int($0))
        }
        buffer.forEach {
            crc.update_checksum(Int($0))
        }
        crc.finish_checksum(messageId)
        return Int(crcHigh) == crc.getMSB() && Int(crcLow) == crc.getLSB()
    }
}
