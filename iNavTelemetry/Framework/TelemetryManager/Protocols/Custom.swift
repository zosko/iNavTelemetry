//
//  Telemetry.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI

class Custom : NSObject{
    private var rcv_buffer : [UInt8] = []
    private var buffer_index : Int = 0
    private var found_header : Bool = false
    private var rcv_length : UInt8 = 0
    
    var packet = TelemetryManager.Packet()
    
    //MARK: Helpers
    private func buffer_get_int16(buffer: [UInt8], index : Int) -> UInt16{
        return UInt16(buffer[index]) << 8 | UInt16(buffer[index + 1])
    }
    private func buffer_get_int32(buffer: [UInt8], index : Int) -> UInt32 {
        return UInt32(buffer[index]) << 24 | UInt32(buffer[index + 1]) << 16 | UInt32(buffer[index + 2]) << 8 | UInt32(buffer[index + 3])
    }
    private func buffer_get_float16(buffer: [UInt8], scale : Double, index : Int) -> Double{
        return Double(buffer_get_int16(buffer: buffer, index: index)) / scale
    }
    private func buffer_get_float32(buffer: [UInt8], scale : Double, index : Int) -> Double{
        return (Double)(buffer_get_int32(buffer: buffer, index: index)) / scale
    }
    private func linearInterpolation(inVal:Double, inMin:Double, inMax:Double, outMin:Double, outMax:Double) -> Double{
        if (inMin == 0 && inMax == 0) {
            return 0.0;
        }
        return (inVal - inMin) / (inMax - inMin) * (outMax - outMin) + outMin;
    }
    
    //MARK: Telemetry functions
    func process_incoming_bytes(incomingData: Data) -> Bool{
        let bytes: [UInt8] = incomingData.map{ $0 }
        let START_FLAG : UInt8 = 0xFE
        let END_FLAG : UInt8 = 0x7F
        var packetReceived = false
        var checksum : UInt8 = 0
        
        for i in 0 ..< bytes.count {
            if(bytes[i] == START_FLAG){
                found_header = true
                buffer_index = 0
                rcv_length = 0
            }
            else if(bytes[i] == END_FLAG){
                
                if (buffer_index >= 2 && (buffer_index - 1) == rcv_length){
                    checksum = rcv_length
                    
                    for i in 0 ..< rcv_length {
                        checksum ^= rcv_buffer[Int(i)];
                        
                        if (checksum == rcv_buffer[buffer_index - 1]){
                            // Packet is good
                            rcv_length = 0
                            buffer_index = 0
                            found_header = false
                            packetReceived = true
                            break;
                        }
                    }
                    break;
                }
            }
            else if (found_header && rcv_length == 0){
                rcv_length = bytes[i]
            }
            else if (found_header && rcv_length > 10) {
                rcv_buffer.append(bytes[i])
                buffer_index += 1
            }
        }
        
        if(packetReceived){
            readPacket(payload: rcv_buffer)
            return true
        }
        return false
    }
    private func readPacket(payload : [UInt8]){
        var ind : Int = 0

        packet.lat = buffer_get_float32(buffer: payload, scale:1e7, index:ind)
        ind += 4

        packet.lng = buffer_get_float32(buffer: payload, scale:1e7, index:ind)
        ind += 4

        packet.alt = Int(buffer_get_int16(buffer: payload, index:ind))
        ind += 2

        packet.gps_sats = Int(payload[ind])
        ind += 1

        packet.distance = Int(buffer_get_int16(buffer: payload, index:ind))
        ind += 2

        packet.speed = Int(payload[ind])
        ind += 1

        packet.voltage = buffer_get_float16(buffer: payload, scale:1e2, index:ind)
        ind += 2

        packet.rssi = Int(payload[ind])
        ind += 1

        packet.current = Int(payload[ind])
        ind += 1

        packet.heading = Int(buffer_get_int16(buffer: payload, index:ind))
        ind += 2
        
        packet.flight_mode = Int(payload[ind])
        ind += 1
        
        packet.fuel = Int(payload[ind])
        ind += 1
        
        packet.pitch = Int(linearInterpolation(inVal: Double(payload[ind]), inMin: 0, inMax: 200, outMin: -100, outMax: 100))
        ind += 1
        
        packet.roll = Int(linearInterpolation(inVal: Double(payload[ind]), inMin: 0, inMax: 200, outMin: -100, outMax: 100))
        ind += 1
    }
}
