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
            DisplayView(viewModel: viewModel, logBookCoordinates: $logBookCoordinates)
            
            
            if viewModel.showPeripherals {
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
                            }.padding(.bottom, 20)
                            
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
                                    logBookCoordinates = logData
                                } catch {
                                    print(error)
                                }
                            } label: {
                                Text(name)
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                            }.padding(.bottom, 20)
                            
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
                        Spacer()
                        if !viewModel.logsData.isEmpty {
                            Button {
                                viewModel.cleanDatabase()
                                viewModel.showListLogs = false
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            }
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
