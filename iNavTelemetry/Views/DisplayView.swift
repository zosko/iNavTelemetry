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
    @Binding var logBookCoordinates: [TelemetryManager.LogTelemetry]?
    
    var body: some View {
        ZStack {
            HStack {
                VStack(spacing: 1) {
                    InstrumentView(type: .latitude(packet: viewModel.telemetry))
                    InstrumentView(type: .longitude(packet: viewModel.telemetry))
                    InstrumentView(type: .satellites(packet: viewModel.telemetry))
                    InstrumentView(type: .distance(packet: viewModel.telemetry))
                    InstrumentView(type: .altitude(packet: viewModel.telemetry))
                    InstrumentView(type: .speed(packet: viewModel.telemetry))
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
                    InstrumentView(type: .flytime(packet: viewModel.telemetry))
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom ,spacing: 1) {
                    InstrumentView(type: .current(packet: viewModel.telemetry))
                    InstrumentView(type: .voltage(packet: viewModel.telemetry))
                    Spacer()
                    ConnectionView(viewModel: viewModel, logBookCoordinates: $logBookCoordinates)
                    CompassView(heading: viewModel.telemetry.packet.heading)
                    AttitudeView(roll: viewModel.telemetry.packet.roll, pitch: viewModel.telemetry.packet.pitch)
                }
            }
            if viewModel.connected && !viewModel.homePositionAdded {
                Text("Waiting for satellites")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(40)
                    .background(Color.black
                                    .opacity(0.5)
                                    .cornerRadius(20))
            }
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(viewModel: .init(), logBookCoordinates: .constant(nil))
            .background(Color.black)
            .previewLayout(.fixed(width: 812, height: 375))
    }
}
