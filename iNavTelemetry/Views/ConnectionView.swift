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
    @Binding var screen: Screen
    
    @State private var showingActionSheetLogs = false
    
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
                        showingActionSheetLogs = true
                    }){
                        Image("log")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60, height:60)
                    }.actionSheet(isPresented: $showingActionSheetLogs){
                        var buttons: [ActionSheet.Button] = viewModel.logsData.map { log in
                            let timestamp = Double(log.pathComponents.last!)!
                            let name = Database.toName(timestamp: timestamp)
                            return .default(Text(name)) {
                                
                                let jsonData = try! Data(contentsOf: log)
                                let logData = try! JSONDecoder().decode([TelemetryManager.LogTelemetry].self, from: jsonData)
                                
                                screen = .logbook(coordinates: logData)
                            }
                        }
                        if buttons.count > 0 {
                            buttons.append(.destructive(Text("Clear database")){
                                viewModel.cleanDatabase()
                            })
                        }
                        return ActionSheet(title: Text("Logs"), buttons: buttons + [.cancel()])
                    }
                }
                
                Button(action: {
                    viewModel.searchDevice()
                }){
                    Image(viewModel.connected ? "power_on" : "power_off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:60, height:60)
                }.actionSheet(isPresented: $viewModel.showingActionSheetPeripherals) {
                    let buttons: [ActionSheet.Button] = viewModel.peripherals.map { peripheral in
                        .default(Text(peripheral.name ?? "")) {
                            viewModel.connectTo(peripheral)
                        }
                    }
                    return ActionSheet(title: Text("Devices"), buttons: buttons + [.cancel()])
                }
            }
        }
        .frame(width: 120, height: 120, alignment: .center)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(viewModel: .init(), screen: .constant(.dashboard))
            .previewLayout(.fixed(width: 120, height: 120))
            .background(Color.blue)
    }
}
