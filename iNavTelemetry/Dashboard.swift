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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(logBookCoordinates: .constant(nil))
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
