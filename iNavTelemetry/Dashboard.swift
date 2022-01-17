//
//  Dashboard.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct Dashboard: View {
    
    @Binding var logBookCoordinates: [LogTelemetry]?
    
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            MapView(viewModel: viewModel)
            DisplayView(viewModel: viewModel)
            
            if viewModel.bluetoothScanning {
                Text("Searching for bluetooth devices")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(40)
                    .background(Color.black
                                    .opacity(0.5)
                                    .cornerRadius(20))
            }
            
            if viewModel.showPeripherals && !viewModel.bluetoothScanning {
                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.peripherals, id:\.self) { peripheral in
                            if let name = peripheral.name, !name.isEmpty {
                                Button {
                                    viewModel.connectTo(peripheral)
                                } label: {
                                    Text(name)
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .bold()
                                }
                                .padding(.bottom, 20)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    Spacer()
                    Button {
                        viewModel.showPeripherals = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if viewModel.showListLogs {
                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    if viewModel.logsData.isEmpty {
                        Text("No logs")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                    }
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.logsData, id:\.self) { log in
                            if let pathName = log.pathComponents.last,
                               let timestamp = Double(pathName),
                               let name = Database.toName(timestamp: timestamp){
                                
                                Button {
                                    guard let jsonData = try? Data(contentsOf: log),
                                          let logData = try? JSONDecoder().decode([LogTelemetry].self,
                                                                                  from: jsonData) else { return }
                                    viewModel.showListLogs = false
                                    logBookCoordinates = logData
                                } label: {
                                    Text(name)
                                        .foregroundColor(.white)
                                        .font(.title)
                                        .bold()
                                }
                                .padding(.bottom, 20)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        Button {
                            viewModel.showListLogs = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        if !viewModel.logsData.isEmpty {
                            Button {
                                viewModel.cleanDatabase()
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
}

#if !DO_NOT_UNIT_TEST
struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(logBookCoordinates: .constant(nil))
            .previewLayout(.fixed(width: 812, height: 375))
    }
}
#endif
