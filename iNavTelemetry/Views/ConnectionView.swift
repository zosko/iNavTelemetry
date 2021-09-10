//
//  ConnectionView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct ConnectionView: View {
    
    enum ProtocolType: Int {
        case smartPort = 0
        case msp = 1
    }
    
    enum Actions {
        case buttonLogbookOpen
        case buttonPower
        case protocolChoosen(protocol: ProtocolType)
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
                Text("S.Port").tag(ProtocolType.smartPort)
                Text("MSP").tag(ProtocolType.msp)
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
                            self.viewRouter.currentPage = .logBook
                        }
                    }
                    return ActionSheet(title: Text("Logs"), buttons: buttons + [.cancel()])
                })
                
                Button(action: {
                    actionSubject.send(.buttonPower)
                }){
                    Image("power_off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
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
