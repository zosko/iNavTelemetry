//
//  MainView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/16/21.
//

import SwiftUI

struct MainView: View {
    
    @State private var logBookCoordinates: [TelemetryManager.LogTelemetry]? = nil
    
    var body: some View {
        ZStack {
            Dashboard(logBookCoordinates: $logBookCoordinates)
            
            if logBookCoordinates != nil {
                Logbook(logBookCoordinates: $logBookCoordinates)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
