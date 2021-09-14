//
//  ConnectionView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct ConnectionView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var viewModel: ConnectionViewModel
    
    var body: some View {
        VStack {
            Text("Protocol")
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(5)
            
            Picker("Protocol", selection: $viewModel.selectedProtocol) {
                Text("S.Port").tag(TelemetryManager.TelemetryType.smartPort)
                Text("MSP").tag(TelemetryManager.TelemetryType.msp)
            }.pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Button(action: {
                    viewModel.showingActionSheetLogs.toggle()
                }){
                    Image("log")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.actionSheet(isPresented: $viewModel.showingActionSheetLogs){
                    let buttons: [ActionSheet.Button] = viewModel.savedLogs.map { log in
                        let timestamp = Double(log.pathComponents.last!)!
                        let name = Database.toName(timestamp: timestamp)
                        return .default(Text(name)) {
                            self.viewRouter.currentPage = .logBook(log)
                        }
                    }
                    return ActionSheet(title: Text("Logs"), buttons: buttons + [.cancel()])
                }
                
                Button(action: {
                    viewModel.searchDevice()
                }){
                    Image("power_off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
        ConnectionView(viewModel: .constant(.init()))
            .previewLayout(.fixed(width: 120, height: 120))
            .background(Color.blue)
    }
}
