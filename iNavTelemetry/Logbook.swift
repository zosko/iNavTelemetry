//
//  Logbook.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import MapKit

struct MapViewLines: UIViewRepresentable {
    let region: MKCoordinateRegion
    let lineCoordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        
        let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
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
          renderer.lineWidth = 5
          return renderer
        }
        return MKOverlayRenderer()
      }
    }
    
}

struct Logbook: View {
    
    @Binding var screen: Screen

    var coordinates: [CLLocationCoordinate2D]
    
    var body: some View {
        return ZStack(alignment: .topLeading)  {
            MapViewLines(region: MKCoordinateRegion(center: coordinates.first!,
                                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                         , lineCoordinates: coordinates)
              .edgesIgnoringSafeArea(.all)
            
            Button(action: {
                screen = .dashboard
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
        Logbook(screen: .constant(.dashboard), coordinates: .init())
    }
}
