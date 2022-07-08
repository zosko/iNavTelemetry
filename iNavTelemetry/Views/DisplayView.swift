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
                    InstrumentView(types: [.distance], telemetry: viewModel.telemetry)
                    InstrumentView(types: [.altitude, .galtitude], telemetry: viewModel.telemetry)
                    InstrumentView(types: [.speed], telemetry: viewModel.telemetry)
                    Spacer()
                }
                Spacer()
                VStack {
                    HStack(spacing: 1) {
                        InstrumentView(types: [.latitude], telemetry: viewModel.telemetry)
                        InstrumentView(types: [.satellites], telemetry: viewModel.telemetry)
                        InstrumentView(types: [.longitude], telemetry: viewModel.telemetry)
                    }
                    Spacer()
                }
                Spacer()
                VStack(spacing: 1) {
                    InstrumentView(types: [.armed], telemetry: viewModel.telemetry)
                    InstrumentView(types: [.signal], telemetry: viewModel.telemetry)
                    if viewModel.telemetry.telemetryType != .msp {
                        InstrumentView(types: [.fuel], telemetry: viewModel.telemetry)
                    }
                    InstrumentView(types: [.flymode], telemetry: viewModel.telemetry)
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom ,spacing: 1) {
                    InstrumentView(types: [.current], telemetry: viewModel.telemetry)
                    InstrumentView(types: [.voltage], telemetry: viewModel.telemetry)
                    InstrumentView(types: [.flytime], telemetry: viewModel.telemetry)
                    Spacer()
                    ConnectionView(viewModel: viewModel)
                    CompassView(viewModel: viewModel)
                    AttitudeView(viewModel: viewModel)
                }
            }
            
            if viewModel.connected &&
                viewModel.telemetry.telemetryType == .unknown {
                Text("Detecting protocol")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(40)
                    .background(Color.black
                                    .opacity(0.5)
                                    .cornerRadius(20))
                Button {
                    viewModel.stopDetectingProtocol()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x:155, y:-40)
            }
            
            if viewModel.connected &&
                !viewModel.homePositionAdded &&
                viewModel.telemetry.telemetryType != .unknown {
                
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
