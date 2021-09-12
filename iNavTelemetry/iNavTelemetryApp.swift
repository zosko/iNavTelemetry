//
//  iNavTelemetryApp.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

@main
struct iNavTelemetryApp: App {
    
    @StateObject var viewRouter = ViewRouter()
    
    var body: some Scene {
        WindowGroup {
            switch viewRouter.currentPage {
            case .dashboard:
                Dashboard().environmentObject(viewRouter)
            case .logBook(_):
                Logbook().environmentObject(viewRouter)
            }
        }
    }
}
