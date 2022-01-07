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
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                if !viewModel.bluetootnConnected {
                    Button(action: {
                        viewModel.getFlightLogs()
                    }){
                        Image("log")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60, height:60)
                    }.buttonStyle(PlainButtonStyle())
                }
                
                Button(action: {
                    viewModel.searchDevice()
                }){
                    Image(viewModel.bluetootnConnected ? "power_on" : "power_off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:60, height:60)
                }.buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 120, height: 120, alignment: .center)
        .padding(10)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(viewModel: .init())
            .previewLayout(.fixed(width: 120, height: 120))
            .background(Color.blue)
    }
}
