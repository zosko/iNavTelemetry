//
//  InstrumentView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct InstrumentView: View {
    var types: [InstrumentType]
    var telemetry: InstrumentTelemetry
    @State private var currentType: Int = 0
    
    var value: String {
        switch types[currentType] {
        case .latitude: return "\(telemetry.location.latitude)"
        case .longitude: return "\(telemetry.location.longitude)"
        case .satellites: return "\(telemetry.packet.gps_sats)"
        case .distance: return "\(telemetry.packet.distance)m"
        case .altitude: return "\(telemetry.packet.alt)m"
        case .galtitude: return "\(telemetry.packet.galt)m"
        case .speed: return "\(telemetry.packet.speed) km/h"
        case .armed: return "\(telemetry.engine.rawValue)"
        case .signal: return "\(telemetry.packet.rssi)%"
        case .fuel: return "\(telemetry.packet.fuel)%"
        case .flymode: return "\(telemetry.stabilization)"
        case .flytime: return "missing"//"\(String(format:"%02ld:%02ld:%02ld",seconds/3600,(seconds/60)%60,seconds%60))"
        case .current: return "\(telemetry.packet.current) amp"
        case .voltage: return "\(telemetry.packet.voltage)v"
        case .direction: return "\(telemetry.direction)"
        }
    }
    
    var warning: Bool {
        switch types[currentType] {
        case .latitude: return telemetry.location.latitude == 0
        case .longitude: return telemetry.location.longitude == 0
        case .satellites: return telemetry.packet.gps_sats < 6
        case .distance: return telemetry.packet.distance > 500
        case .altitude: return telemetry.packet.alt > 300
        case .galtitude: return telemetry.packet.galt > 700
        case .speed: return telemetry.packet.speed > 100
        case .armed: return telemetry.engine == .armed
        case .signal: return telemetry.packet.rssi < 20
        case .fuel: return telemetry.packet.fuel < 20
        case .flymode: return telemetry.stabilization == .manual
        case .flytime: return false
        case .current: return telemetry.packet.current > 30
        case .voltage: return telemetry.packet.voltage < 7
        case .direction: return false
        }
    }
    
    var body: some View {
        VStack {
            if types[currentType] == .direction {
                Image(systemName: types[currentType].imageName)
                    .rotationEffect(.degrees(Double(value) ?? 0))
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
            } else {
                Text(types[currentType].name)
                    .bold()
                    .foregroundColor(warning ? Color.white : Color.black)
                Text(value)
                    .bold()
                    .foregroundColor(warning ? Color.white : Color.black)
            }
        }
        .modifier(IndicatorTap(showIndicator: types.count > 1))
        .frame(width: 100, height: 40, alignment: .center)
        .background(warning ? Color.red : Color.white.opacity(0.5))
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
        InstrumentView(types: [.armed, .distance],
                       telemetry: InstrumentTelemetry(packet: .init(), telemetryType: .smartPort))
            .previewLayout(.fixed(width: 100, height: 50))
    }
}
