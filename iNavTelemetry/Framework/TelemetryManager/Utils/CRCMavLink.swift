//
//  CRCMavLink.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 2.2.22.
//

import Foundation

final class CRCMAVLink {
    
    let MAVLINK_MESSAGE_CRCS: [Int] = [50, 124, 137, 0, 237, 217, 104, 119, 0, 0, 0, 89, 0, 0, 0, 0, 0, 0, 0, 0, 214, 159, 220, 168, 24, 23, 170, 144, 67, 115, 39, 246, 185, 104, 237, 244, 222, 212, 9, 254, 230, 28, 28, 132, 221, 232, 11, 153, 41, 39, 78, 196, 0, 0, 15, 3, 0, 0, 0, 0, 0, 167, 183, 119, 191, 118, 148, 21, 0, 243, 124, 0, 0, 38, 20, 158, 152, 143, 0, 0, 0, 106, 49, 22, 143, 140, 5, 150, 0, 231, 183, 63, 54, 47, 0, 0, 0, 0, 0, 0, 175, 102, 158, 208, 56, 93, 138, 108, 32, 185, 84, 34, 174, 124, 237, 4, 76, 128, 56, 116, 134, 237, 203, 250, 87, 203, 220, 25, 226, 46, 29, 223, 85, 6, 229, 203, 1, 195, 109, 168, 181, 47, 72, 131, 127, 0, 103, 154, 178, 200, 134, 219, 208, 188, 84, 22, 19, 21, 134, 0, 78, 68, 189, 127, 154, 21, 21, 144, 1, 234, 73, 181, 22, 83, 167, 138, 234, 240, 47, 189, 52, 174, 229, 85, 159, 186, 72, 0, 0, 0, 0, 92, 36, 71, 98, 120, 0, 0, 0, 0, 134, 205, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 69, 101, 50, 202, 17, 162, 0, 0, 0, 0, 0, 0, 207, 0, 0, 0, 163, 105, 151, 35, 150, 0, 0, 0, 0, 0, 0, 90, 104, 85, 95, 130, 184, 81, 8, 204, 49, 170, 44, 83, 46, 0]
    private let CRC_INIT_VALUE: Int = 0xffff
    private var crcValue: Int = 0
    
    // MARK: - Initializer
    init(){
        start_checksum()
    }
    
    // MARK: - Internal functions
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
