//
//  MapView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import MapKit
import Combine

struct MapView: View {
    
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.planeLocation) { plane in
                MapPin(coordinate: plane.coordinate, tint: .red)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: .init())
    }
}
