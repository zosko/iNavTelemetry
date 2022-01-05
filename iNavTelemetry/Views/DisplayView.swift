//
//  DisplayView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct DisplayView: View {
    
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            HStack {
                VStack(spacing: 1) {
                    InstrumentView(types: [.distance(packet: viewModel.telemetry)])
                    InstrumentView(types: [.altitude(packet: viewModel.telemetry), .galtitude(packet: viewModel.telemetry)])
                    InstrumentView(types: [.speed(packet: viewModel.telemetry)])
                    Spacer()
                }
                Spacer()
                VStack {
                    HStack(spacing: 1) {
                        InstrumentView(types: [.latitude(packet: viewModel.telemetry)])
                        InstrumentView(types: [.satellites(packet: viewModel.telemetry)])
                        InstrumentView(types: [.longitude(packet: viewModel.telemetry)])
                    }
                    Spacer()
                }
                Spacer()
                VStack(spacing: 1) {
                    InstrumentView(types: [.armed(packet: viewModel.telemetry)])
                    InstrumentView(types: [.signal(packet: viewModel.telemetry)])
                    if viewModel.selectedProtocol != TelemetryManager.TelemetryType.msp {
                        InstrumentView(types: [.fuel(packet: viewModel.telemetry)])
                    }
                    InstrumentView(types: [.flymode(packet: viewModel.telemetry)])
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom ,spacing: 1) {
                    InstrumentView(types: [.current(packet: viewModel.telemetry)])
                    InstrumentView(types: [.voltage(packet: viewModel.telemetry)])
                    InstrumentView(types: [.flytime(seconds: viewModel.seconds)])
                    Spacer()
                    ConnectionView(viewModel: viewModel)
                    CompassView(viewModel: viewModel)
                    AttitudeView(viewModel: viewModel)
                }
            }
            if viewModel.connected && !viewModel.homePositionAdded {
                VStack {
                    Text("Waiting for satellites")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(40)
                        .background(Color.black
                                        .opacity(0.5)
                                        .cornerRadius(20))
                    Text("Protocol detected: \(viewModel.telemetry.telemetryType.name)")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .offset(y: -40)
                }
            }
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(viewModel: .init())
            .background(Color.black)
            .previewLayout(.fixed(width: 812, height: 375))
    }
}
