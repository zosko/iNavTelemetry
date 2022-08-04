//
//  TelemetryTypes.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 1/16/22.
//

import Foundation

enum TelemetryType {
    case unknown
    case smartPort
    case msp
    case custom
    case mavLink_v1
    case mavLink_v2
    
    var name: String {
        switch self {
        case .unknown: return "Unknown"
        case .smartPort: return "S.Port"
        case .msp: return "MSP"
        case .custom: return "Custom"
        case .mavLink_v1: return "MavLink V1"
        case .mavLink_v2: return "MavLink V2"
        }
        
    }
}

enum BluetoothType {
    case hm10
    case frskyBuildIn
    case tbsCrossfire
    
    var uuidService: String {
        switch self {
        case .frskyBuildIn: return "FFF0"
        case .hm10: return "FFE0"
        case .tbsCrossfire: return "180F"
        }
    }
    
    var uuidChar: String {
        switch self {
        case .frskyBuildIn: return "FFF6"
        case .hm10: return "FFE1"
        case .tbsCrossfire: return "2A19"
        }
    }
}

enum InstrumentType {
    case latitude
    case longitude
    case satellites
    case distance
    case altitude
    case galtitude
    case speed
    case armed
    case signal
    case fuel
    case flymode
    case flytime
    case current
    case voltage
    case direction
    
    var name: String {
        switch self {
        case .latitude: return "Latitude"
        case .longitude: return "Longitude"
        case .satellites: return "Satellites"
        case .distance: return "Distance"
        case .altitude: return "Altitude"
        case .galtitude: return "GPS Alt"
        case .speed: return "Speed"
        case .armed: return "Engine"
        case .signal: return "Signal"
        case .fuel: return "Fuel"
        case .flymode: return "Fly mode"
        case .flytime: return "Fly time"
        case .current: return "Current"
        case .voltage: return "Voltage"
        case .direction: return ""
        }
    }
    
    var imageName: String {
        switch self {
        case .latitude: return "network"
        case .longitude: return "network"
        case .satellites: return "bonjour"
        case .distance: return "shuffle"
        case .altitude: return "mount"
        case .galtitude: return "mount"
        case .speed: return "speedometer"
        case .armed: return "shield"
        case .signal: return "antenna.radiowaves.left.and.right"
        case .fuel: return "fuelpump"
        case .flymode: return "airplane.circle"
        case .flytime: return "timer"
        case .current: return "directcurrent"
        case .voltage: return "minus.plus.batteryblock"
        case .direction: return "shift.fill"
        }
    }
}

