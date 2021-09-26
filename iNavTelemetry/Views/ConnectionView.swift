//
//  ConnectionView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct ConnectionView: View {
    
    @ObservedObject var viewModel: AppViewModel
    @Binding var logBookCoordinates: [TelemetryManager.LogTelemetry]?
    
    var body: some View {
        VStack {
            Spacer()
            if !viewModel.connected {
                Text("Protocol")
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(5)
                
                Picker("Protocol", selection: $viewModel.selectedProtocol) {
                    Text(TelemetryManager.TelemetryType.smartPort.name).tag(TelemetryManager.TelemetryType.smartPort)
                    Text(TelemetryManager.TelemetryType.msp.name).tag(TelemetryManager.TelemetryType.msp)
                }.pickerStyle(SegmentedPickerStyle())
            }
            
            HStack {
                Spacer()
                
                if !viewModel.connected {
                    Button(action: {
                        viewModel.showListLogs = true
                    }){
                        Image("log")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60, height:60)
                    }
                }
                
                Button(action: {
                    viewModel.searchDevice()
                }){
                    Image(viewModel.connected ? "power_on" : "power_off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:60, height:60)
                }
            }
        }
        .frame(width: 120, height: 120, alignment: .center)
        .padding(10)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(viewModel: .init(), logBookCoordinates: .constant(nil))
            .previewLayout(.fixed(width: 120, height: 120))
            .background(Color.blue)
    }
}
