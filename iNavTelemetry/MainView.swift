//
//  MainView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/16/21.
//

import SwiftUI

enum Screen {
    case dashboard
    case logbook(url: URL)
}

struct MainView: View {
    
    @State private var screen: Screen = .dashboard
    
    var body: some View {
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
