//
//  MapViewModelView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/6/21.
//

import Foundation
import Combine
import MapKit


class MapViewModelView: ObservableObject {
    @Published var region: MKCoordinateRegion
    
    private let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    
    init(){
        self.region = MKCoordinateRegion()
        self.region.span = span
    }
    
    func updateLocation(location: CLLocationCoordinate2D) {
        self.region = MKCoordinateRegion(center: location, span: span)
    }
}
