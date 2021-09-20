//
//  Logbook.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import MapKit

struct MapViewLines: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = .satellite
        mapView.delegate = context.coordinator
        if let firstCoordinate = coordinates.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            mapView.region = .init(center: firstCoordinate, span: span)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
      var parent: MapViewLines

      init(_ parent: MapViewLines) {
        self.parent = parent
      }

      func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
          let renderer = MKPolylineRenderer(polyline: routePolyline)
          renderer.strokeColor = UIColor.systemBlue
          renderer.lineWidth = 4
          return renderer
        }
        return MKOverlayRenderer()
      }
    }
    
}

struct Logbook: View {
    
    @Binding var logBookCoordinates: [TelemetryManager.LogTelemetry]?
    
    private var coordinates: [CLLocationCoordinate2D] {
        guard let logBook = logBookCoordinates else { return [] }
        return logBook.map{ $0.location }
    }
    
    var body: some View {
        return ZStack(alignment: .topLeading)  {
            MapViewLines(coordinates: coordinates)
              .edgesIgnoringSafeArea(.all)
            
            Button(action: {
                logBookCoordinates = nil
            }){
                Image("back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }.frame(width: 50, height: 50)
        }
    }
}

struct Logbook_Previews: PreviewProvider {
    static var previews: some View {
        Logbook(logBookCoordinates: .constant(nil))
    }
}
