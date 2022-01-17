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
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.allPlanes) { plane in
                MapAnnotation(coordinate: plane.coordinate) {
                    Circle()
                        .fill(plane.mine ? Color.red : Color.blue)
                        .frame(width: 15, height: 15)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

#if !DO_NOT_UNIT_TEST
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: .init())
    }
}
#endif
