//
//  ConnectionView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct ConnectionView: View {
    
    enum Actions {
        case logBook
        case search
        case protocolChoosen(protocol: Telemetry.TelemetryType)
    }
    
    var actionSubject = PassthroughSubject<Actions, Never>()
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject private var viewModel = ConnectionViewModel()
    
    var body: some View {
        VStack {
            Text("Protocol")
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .cornerRadius(5)
            
            Picker("Protocol", selection: $viewModel.selectedProtocol) {
                Text("S.Port").tag(Telemetry.TelemetryType.SMARTPORT)
                Text("MSP").tag(Telemetry.TelemetryType.MSP)
            }.onChange(of: viewModel.selectedProtocol, perform: { value in
                actionSubject.send(.protocolChoosen(protocol: value))
            }).pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Button(action: {
                    viewModel.showingActionSheetLogs.toggle()
                }){
                    Image("log")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.actionSheet(isPresented: $viewModel.showingActionSheetLogs, content: {
                    let buttons: [ActionSheet.Button] = viewModel.savedLogs.map { title in
                        .default(Text(title)) {
                            self.viewRouter.currentPage = .logBook(log: "")
                        }
                    }
                    return ActionSheet(title: Text("Logs"), buttons: buttons + [.cancel()])
                })
                
                Button(action: {
                    actionSubject.send(.search)
                    viewModel.searchDevice()
                }){
                    Image("power_off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.actionSheet(isPresented: $viewModel.showingActionSheetPeripherals, content: {
                    let buttons: [ActionSheet.Button] = viewModel.peripherals.map { peripheral in
                        .default(Text(peripheral.name ?? "")) {
                            viewModel.connectTo(peripheral)
                        }
                    }
                    return ActionSheet(title: Text("Devices"), buttons: buttons + [.cancel()])
                })
            }
        }
        .frame(width: 120, height: 120, alignment: .center)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
            .previewLayout(.fixed(width: 120, height: 120))
            .background(Color.blue)
    }
}
