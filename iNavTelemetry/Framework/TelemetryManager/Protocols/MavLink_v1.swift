//
//  MavLink_v1.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/17/21.
//

import Foundation
import CoreLocation

final class MavLink_v1: TelemetryProtocol {
    
    enum State {
        case IDLE
        case LENGTH
        case INDEX
        case SYSTEM_ID
        case COMPONENT_ID
        case MESSAGE_ID
        case PAYLOAD
        case CRC
    }
    
    private var crc = CRCMAVLink()
    private var state = State.IDLE
    private var buffer: [UInt8] = [UInt8](repeating: 0, count: 255)
    private var payloadIndex = 0
    private var packetLength: UInt8 = 0
    private var packetIndex: UInt8 = 0
    private var systemId: UInt8 = 0
    private var componentId: UInt8 = 0
    private var messageId: UInt8 = 0
    private var crcLow: UInt8 = 0
    private var crcHigh: UInt8 = 0
    private var gotRadioStatus = false

    private let PACKET_MARKER = 0xFE
    
    private let MAVLINK_MSG_ID_HEARTBEAT: UInt8 = 0
    private let MAVLINK_MSG_ID_SYS_STATUS: UInt8 = 1
    private let MAVLINK_MSG_ID_GPS_RAW_INT: UInt8 = 24
    private let MAVLINK_MSG_ID_ATTITUDE: UInt8 = 30
    private let MAVLINK_MSG_ID_GLOBAL_POSITION_INT: UInt8 = 33
    private let MAVLINK_MSG_ID_RC_CHANNELS_RAW: UInt8 = 35
    private let MAVLINK_MSG_ID_GPS_GLOBAL_ORIGIN: UInt8 = 49
    private let MAVLINK_MSG_ID_VFR_HUD: UInt8 = 74
    private let MAVLINK_MSG_ID_RADIO_STATUS: UInt8 = 109
    
    private let MAV_PACKET_GLOBAL_POSITION_INT_LENGTH = 28
    private let MAV_PACKET_STATUS_LENGTH = 31
    private let MAV_PACKET_HEARTBEAT_LENGTH = 9
    private let MAV_PACKET_RC_CHANNEL_LENGTH = 22
    private let MAV_PACKET_ATTITUDE_LENGTH = 28
    private let MAV_PACKET_VFR_HUD_LENGTH = 20
    private let MAV_PACKET_GPS_RAW_LENGTH = 30
    private let MAV_PACKET_RADIO_STATUS_LENGTH = 9
    
    var packet = Packet()
    var newLatitude = false
    var newLongitude = false
    var originLatitude = 0.0
    var originLongitude = 0.0
    var latitude = 0.0
    var longitude = 0.0
    
    // MARK: Internal methods
    func process(_ incomingData: Data) -> Bool {
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
                break
            case .MESSAGE_ID:
                messageId = data[i]
                state = .PAYLOAD
                payloadIndex = 0
                buffer = [UInt8](repeating: 0, count: Int(packetLength))
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
    
    // MARK: - Private methods
    private func processPacket() {
        if (messageId == MAVLINK_MSG_ID_SYS_STATUS && packetLength == MAV_PACKET_STATUS_LENGTH) {
            packet.voltage = Double(littleEndian_get_int16(buffer: buffer, index: 15)) / 1000.0
            packet.current = Int(Double(littleEndian_get_int16(buffer: buffer, index: 17)) / 100.0)
            packet.fuel = Int(buffer[30])
        }
        else if (messageId == MAVLINK_MSG_ID_HEARTBEAT && packetLength == MAV_PACKET_HEARTBEAT_LENGTH) {
            packet.flight_mode = Int(buffer[6])
        }
        else if (messageId == MAVLINK_MSG_ID_RC_CHANNELS_RAW && packetLength == MAV_PACKET_RC_CHANNEL_LENGTH) {
            let rssi = Int(buffer[20] & 0xff)
            if !gotRadioStatus {
                packet.rssi = rssi == 255 ? -1 : rssi * 100 / 254
            }
        }
        else if (messageId == MAVLINK_MSG_ID_ATTITUDE && packetLength == MAV_PACKET_ATTITUDE_LENGTH) {
            let roll:Float = [buffer[4],buffer[5],buffer[6],buffer[7]].withUnsafeBytes { $0.load(as: Float.self) }
            let pitch:Float = [buffer[8],buffer[9],buffer[10],buffer[11]].withUnsafeBytes { $0.load(as: Float.self) }
            packet.roll = Int(rad2deg(Double(roll)))
            packet.pitch = Int(rad2deg(Double(pitch)))
        }
        else if (messageId == MAVLINK_MSG_ID_VFR_HUD && packetLength == MAV_PACKET_VFR_HUD_LENGTH) {
            let speed:Float = [buffer[4],buffer[5],buffer[6],buffer[7]].withUnsafeBytes { $0.load(as: Float.self) }
            let alt:Float = [buffer[8],buffer[9],buffer[10],buffer[11]].withUnsafeBytes { $0.load(as: Float.self) }
            packet.speed = Int(speed)
            packet.alt = Int(alt / 1000)
        }
        else if (messageId == MAVLINK_MSG_ID_RADIO_STATUS && packetLength == MAV_PACKET_RADIO_STATUS_LENGTH) {
            let rssi = Int(buffer[3] & 0xff)
            packet.rssi = rssi == 255 ? -1 : rssi * 100 / 254
            gotRadioStatus = true
        }
        else if (messageId == MAVLINK_MSG_ID_GPS_RAW_INT && packetLength == MAV_PACKET_GPS_RAW_LENGTH) {
            packet.gps_sats = Int(buffer[29])
        }
        else if (messageId == MAVLINK_MSG_ID_GPS_GLOBAL_ORIGIN) {
            originLatitude = Double(littleEndian_get_int32(buffer: buffer, index: 3)) / 10000000
            originLongitude = Double(littleEndian_get_int32(buffer: buffer, index: 7)) / 10000000
            self.gpsCoordinate()
        }
        else if (messageId == MAVLINK_MSG_ID_GLOBAL_POSITION_INT && packetLength == MAV_PACKET_GLOBAL_POSITION_INT_LENGTH) {
            latitude = Double(littleEndian_get_int32(buffer: buffer, index: 7)) / 10000000
            longitude = Double(littleEndian_get_int32(buffer: buffer, index: 11)) / 10000000
            packet.heading = Int(littleEndian_get_int16(buffer: buffer, index: 27)) / 100
            
            newLatitude = true
            newLongitude = true
            
            self.gpsCoordinate()
        }
        else {
            print("not parsed [messageID] \(messageId) [packetLength] \(packetLength) [data] \(buffer)")
        }
    }
    private func gpsCoordinate() {
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
        crc.update_checksum(Int(packetIndex))
        crc.update_checksum(Int(systemId))
        crc.update_checksum(Int(componentId))
        crc.update_checksum(Int(messageId))
        buffer.forEach {
            crc.update_checksum(Int($0))
        }
        crc.finish_checksum(Int(messageId))
        return crcHigh == crc.getMSB() && crcLow == crc.getLSB()
    }
}
