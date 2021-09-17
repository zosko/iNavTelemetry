//
//  MainView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/16/21.
//

import SwiftUI

enum Screen {
    case dashboard
    case logbook(coordinates: [TelemetryManager.LogTelemetry])
}

struct MainView: View {
    
    @State private var screen: Screen = .dashboard
    
    var body: some View {
        switch screen {
        case .dashboard:
            Dashboard(screen: $screen)
                .animation(.easeOut)
                .transition(.opacity)
        case .logbook(let coordinates):
            let mapToLocations = coordinates.map { $0.location }
            Logbook(screen: $screen, coordinates: mapToLocations)
                .animation(.easeOut)
                .transition(.opacity)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
