//
//  MapView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import MapKit

struct City: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    
    @State private var cities: [City] = [
            City(coordinate: .init(latitude: 40.7128, longitude: 74.0060)),
            City(coordinate: .init(latitude: 37.7749, longitude: 122.4194)),
            City(coordinate: .init(latitude: 47.6062, longitude: 122.3321))
        ]
    
    @ObservedObject private var model = MapViewModelView()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $model.region, annotationItems: cities) { city in
                MapPin(coordinate: city.coordinate, tint: .green)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
