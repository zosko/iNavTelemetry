//
//  MapView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @ObservedObject private var model = MapViewModelView()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $model.region)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
