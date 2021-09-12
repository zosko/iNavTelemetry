//
//  InstrumentView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct InstrumentView: View {
    
    enum InstrumentType {
        case latitude
        case longitude
        case satelittes
        case distance
        case altitude
        case speed
        case armed
        case signal
        case fuel
        case flymode
        case flytime
        case current
        case voltage
        
        var name: String {
            switch self {
            case .latitude: return "Latitude"
            case .longitude: return "Longitude"
            case .satelittes: return "Satelittes"
            case .distance: return "Distance"
            case .altitude: return "Altitude"
            case .speed: return "Speed"
            case .armed: return "Armed"
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
            case .latitude, .longitude: return "network"
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
    }
    
    var type: InstrumentType
    @Binding var value: String
    
    var body: some View {
        VStack {
            Text(type.name).bold()
            Text(value).bold()
        }
        .frame(width: 100, height: 40, alignment: .center)
        .background(Color.white.opacity(0.5))
        .cornerRadius(5)
    }
}

struct InstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentView(type: .latitude, value: .constant("44"))
            .previewLayout(.fixed(width: 100, height: 50))
    }
}
