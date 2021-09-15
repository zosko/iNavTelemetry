//
//  Dashboard.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct Dashboard: View {
    
    @Binding var screen: Screen
    
    var body: some View {
        ZStack {
            MapView()
            DisplayView(screen: $screen)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(screen: .constant(.dashboard))
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
