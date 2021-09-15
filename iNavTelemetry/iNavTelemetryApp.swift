//
//  iNavTelemetryApp.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

enum Screen {
    case dashboard
    case logbook(url: URL)
}

@main
struct iNavTelemetryApp: App {
    
    @State private var screen: Screen = .dashboard
    
    var body: some Scene {
        WindowGroup {
            switch screen {
            case .dashboard:
                Dashboard(screen: $screen)
                    .animation(.easeOut)
                    .transition(.opacity)
            case .logbook(let url):
                Logbook(log: url, screen: $screen)
                    .animation(.easeOut)
                    .transition(.opacity)
            }
        }
    }
}
