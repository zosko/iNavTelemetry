//
//  Dashboard.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct Dashboard: View {
    
    @Binding var logBookCoordinates: [TelemetryManager.LogTelemetry]?
    
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
                            let name = peripheral.name ?? "no-name"
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
                            let timestamp = Double(log.pathComponents.last!)!
                            let name = Database.toName(timestamp: timestamp)
                            
                            Button {
                                do {
                                    let jsonData = try Data(contentsOf: log)
                                    let logData = try JSONDecoder().decode([TelemetryManager.LogTelemetry].self, from: jsonData)
                                    viewModel.showListLogs = false
                                    logBookCoordinates = logData
                                } catch {
                                    print(error)
                                }
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

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(logBookCoordinates: .constant(nil))
            .previewLayout(.fixed(width: 812, height: 375))
    }
}
