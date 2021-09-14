//
//  InstrumentView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct InstrumentView: View {
    
    enum InstrumentType {
        case latitude(packet: TelemetryManager.InstrumentTelemetry)
        case longitude(packet: TelemetryManager.InstrumentTelemetry)
        case satelittes(packet: TelemetryManager.InstrumentTelemetry)
        case distance(packet: TelemetryManager.InstrumentTelemetry)
        case altitude(packet: TelemetryManager.InstrumentTelemetry)
        case speed(packet: TelemetryManager.InstrumentTelemetry)
        case armed(packet: TelemetryManager.InstrumentTelemetry)
        case signal(packet: TelemetryManager.InstrumentTelemetry)
        case fuel(packet: TelemetryManager.InstrumentTelemetry)
        case flymode(packet: TelemetryManager.InstrumentTelemetry)
        case flytime(packet: TelemetryManager.InstrumentTelemetry)
        case current(packet: TelemetryManager.InstrumentTelemetry)
        case voltage(packet: TelemetryManager.InstrumentTelemetry)
        
        var name: String {
            switch self {
            case .latitude: return "Latitude"
            case .longitude: return "Longitude"
            case .satelittes: return "Satelittes"
            case .distance: return "Distance"
            case .altitude: return "Altitude"
            case .speed: return "Speed"
            case .armed: return "Engine"
            case .signal: return "Signal"
            case .fuel: return "Fuel"
            case .flymode: return "Fly mode"
            case .flytime: return "Fly time"
            case .current: return "Current"
            case .voltage: return "Voltage"
            }
        }
        
        var imageName: String {
            switch self {
            case .latitude: return "network"
            case .longitude: return "network"
            case .satelittes: return "bonjour"
            case .distance: return "shuffle"
            case .altitude: return "mount"
            case .speed: return "speedometer"
            case .armed: return "shield"
            case .signal: return "antenna.radiowaves.left.and.right"
            case .fuel: return "fuelpump"
            case .flymode: return "airplane.circle"
            case .flytime: return "timer"
            case .current: return "directcurrent"
            case .voltage: return "minus.plus.batteryblock"
            }
        }
        
        var value: String {
            switch self {
            case .latitude(let packet): return "\(packet.location.latitude)"
            case .longitude(let packet): return "\(packet.location.longitude)"
            case .satelittes(let packet): return "\(packet.packet.gps_sats)"
            case .distance(let packet): return "\(packet.packet.distance)"
            case .altitude(let packet): return "\(packet.packet.alt)"
            case .speed(let packet): return "\(packet.packet.speed)"
            case .armed(let packet): return "\(packet.engine.rawValue)"
            case .signal(let packet): return "\(packet.packet.rssi)"
            case .fuel(let packet): return "\(packet.packet.fuel)"
            case .flymode(let packet): return "\(packet.stabilization)"
            case .flytime(let packet): return "\(packet.flyTime)"
            case .current(let packet): return "\(packet.packet.current)"
            case .voltage(let packet): return "\(packet.packet.voltage)"
            }
        }
    }

    var type: InstrumentType
    
    var body: some View {
        VStack {
            Text(type.name).bold()
            Text(type.value).bold()
        }
        .frame(width: 100, height: 40, alignment: .center)
        .background(Color.white.opacity(0.5))
        .cornerRadius(5)
    }
}

struct InstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentView(type: .armed(packet: .init(packet: .init(), telemetryType: .smartPort, flyTime: 0)))
            .previewLayout(.fixed(width: 100, height: 50))
    }
}
