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
                    InstrumentView(type: .distance(packet: viewModel.telemetry))
                    InstrumentView(type: .altitude(packet: viewModel.telemetry))
                    InstrumentView(type: .speed(packet: viewModel.telemetry))
                    Spacer()
                }
                Spacer()
                VStack {
                    HStack(spacing: 1) {
                        InstrumentView(type: .latitude(packet: viewModel.telemetry))
                        InstrumentView(type: .satellites(packet: viewModel.telemetry))
                        InstrumentView(type: .longitude(packet: viewModel.telemetry))
                    }
                    Spacer()
                }
                Spacer()
                VStack(spacing: 1) {
                    InstrumentView(type: .armed(packet: viewModel.telemetry))
                    InstrumentView(type: .signal(packet: viewModel.telemetry))
                    if viewModel.selectedProtocol != TelemetryManager.TelemetryType.msp {
                        InstrumentView(type: .fuel(packet: viewModel.telemetry))
                    }
                    InstrumentView(type: .flymode(packet: viewModel.telemetry))
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom ,spacing: 1) {
                    InstrumentView(type: .current(packet: viewModel.telemetry))
                    InstrumentView(type: .voltage(packet: viewModel.telemetry))
                    InstrumentView(type: .flytime(seconds: viewModel.seconds))
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
