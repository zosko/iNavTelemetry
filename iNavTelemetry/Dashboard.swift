//
//  Dashboard.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct Dashboard: View {
    
    var body: some View {
        ZStack {
            MapView()
            DisplayView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
