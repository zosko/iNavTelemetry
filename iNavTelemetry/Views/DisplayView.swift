//
//  DisplayView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct DisplayView: View {
    
    @State private var viewModel = ConnectionViewModel()
    
    var body: some View {
        ZStack {
            HStack {
                VStack(spacing: 1) {
                    InstrumentView(type: .latitude(packet: viewModel.telemetry))
                    InstrumentView(type: .longitude(packet: viewModel.telemetry))
                    InstrumentView(type: .satelittes(packet: viewModel.telemetry))
                    InstrumentView(type: .distance(packet: viewModel.telemetry))
                    InstrumentView(type: .altitude(packet: viewModel.telemetry))
                    InstrumentView(type: .speed(packet: viewModel.telemetry))
                    Spacer()
                }
                Spacer()
                VStack(spacing: 1) {
                    InstrumentView(type: .armed(packet: viewModel.telemetry))
                    InstrumentView(type: .signal(packet: viewModel.telemetry))
                    InstrumentView(type: .fuel(packet: viewModel.telemetry))
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
                    ConnectionView(viewModel: $viewModel)
                    CompassView(heading: viewModel.telemetry.packet.heading)
                    AttitudeView(roll: viewModel.telemetry.packet.roll, pitch: viewModel.telemetry.packet.pitch)
                }
            }
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
            .background(Color.black)
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
