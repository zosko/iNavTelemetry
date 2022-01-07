//
//  InstrumentView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct InstrumentView: View {
    var types: [InstrumentType]

    @State private var currentType: Int = 0
    
    var body: some View {
        VStack {
            Text(types[currentType].name).bold()
                .foregroundColor(types[currentType].warning ? Color.red : Color.black)
            Text(types[currentType].value).bold()
                .foregroundColor(types[currentType].warning ? Color.red : Color.black)
        }
        .modifier(IndicatorTap(showIndicator: types.count > 1))
        .frame(width: 100, height: 40, alignment: .center)
        .background(Color.white.opacity(0.5))
        .cornerRadius(5)
        .onTapGesture {
            guard types.count > 1 else { return }
            
            let nextElement = currentType + 1
            if nextElement > types.count - 1 {
                currentType = 0
            } else {
                currentType = nextElement
            }
        }
    }
}

struct IndicatorTap: ViewModifier {
    var showIndicator: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showIndicator {
                HStack {
                    Image(systemName: "arrow.left")
                        .font(.caption)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct InstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentView(types: [.armed(packet: .init(packet: .init(), telemetryType: .smartPort)),
                               .flymode(packet: .init(packet: .init(), telemetryType: .smartPort))])
            .previewLayout(.fixed(width: 100, height: 50))
    }
}

enum InstrumentType {
    case latitude(packet: TelemetryManager.InstrumentTelemetry)
    case longitude(packet: TelemetryManager.InstrumentTelemetry)
    case satellites(packet: TelemetryManager.InstrumentTelemetry)
    case distance(packet: TelemetryManager.InstrumentTelemetry)
    case altitude(packet: TelemetryManager.InstrumentTelemetry)
    case galtitude(packet: TelemetryManager.InstrumentTelemetry)
    case speed(packet: TelemetryManager.InstrumentTelemetry)
    case armed(packet: TelemetryManager.InstrumentTelemetry)
    case signal(packet: TelemetryManager.InstrumentTelemetry)
    case fuel(packet: TelemetryManager.InstrumentTelemetry)
    case flymode(packet: TelemetryManager.InstrumentTelemetry)
    case flytime(seconds: Int)
    case current(packet: TelemetryManager.InstrumentTelemetry)
    case voltage(packet: TelemetryManager.InstrumentTelemetry)
    
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
        }
    }
    var value: String {
        switch self {
        case .latitude(let packet): return "\(packet.location.latitude)"
        case .longitude(let packet): return "\(packet.location.longitude)"
        case .satellites(let packet): return "\(packet.packet.gps_sats)"
        case .distance(let packet): return "\(packet.packet.distance)m"
        case .altitude(let packet): return "\(packet.packet.alt)m"
        case .galtitude(let packet): return "\(packet.packet.galt)m"
        case .speed(let packet): return "\(packet.packet.speed) km/h"
        case .armed(let packet): return "\(packet.engine.rawValue)"
        case .signal(let packet): return "\(packet.packet.rssi)%"
        case .fuel(let packet): return "\(packet.packet.fuel)%"
        case .flymode(let packet): return "\(packet.stabilization)"
        case .flytime(let seconds): return "\(String(format:"%02ld:%02ld:%02ld",seconds/3600,(seconds/60)%60,seconds%60))"
        case .current(let packet): return "\(packet.packet.current) amp"
        case .voltage(let packet): return "\(packet.packet.voltage)v"
        }
    }
    
    var warning: Bool {
        switch self {
        case .latitude(let packet): return packet.location.latitude == 0
        case .longitude(let packet): return packet.location.longitude == 0
        case .satellites(let packet): return packet.packet.gps_sats < 6
        case .distance(let packet): return packet.packet.distance > 500
        case .altitude(let packet): return packet.packet.alt > 300
        case .galtitude(let packet): return packet.packet.galt > 700
        case .speed(let packet): return packet.packet.speed > 100
        case .armed(let packet): return packet.engine == .armed
        case .signal(let packet): return packet.packet.rssi < 20
        case .fuel(let packet): return packet.packet.fuel < 20
        case .flymode(let packet): return packet.stabilization == .manual
        case .flytime(_): return false
        case .current(let packet): return packet.packet.current > 30
        case .voltage(let packet): return packet.packet.voltage < 7
        }
    }
}
