//
//  LogScreen.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import MapKit

class LogScreen: UIViewController, MKMapViewDelegate {

    // MARK: Public Variable
    public var logData : [TelemetryStruct] = []
    
    // MARK: IBOutlets
    @IBOutlet var mapPlane : MKMapView!
    
    //MARK: - Variables
    var planeAnnotation : LocationPointAnnotation!
    var gsAnnotation : LocationPointAnnotation!
    var oldLocation : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        planeAnnotation = LocationPointAnnotation()
        planeAnnotation.title = "My Plane"
        planeAnnotation.imageName = "my_plane"
        
        gsAnnotation = LocationPointAnnotation()
        gsAnnotation.title = "Ground Station"
        gsAnnotation.imageName = "gs"
        mapPlane.addAnnotations([gsAnnotation,planeAnnotation])

        let location = CLLocation(latitude: logData.first?.lat ?? 0, longitude: logData.first?.lng ?? 0)
        gsAnnotation.coordinate = location.coordinate
        let region = MKCoordinateRegion(center: gsAnnotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapPlane.setRegion(region, animated: true)

        oldLocation = location.coordinate
        for packet in logData {
            let newLocation = CLLocation(latitude: packet.lat, longitude: packet.lng)
            let polyline = MKPolyline(coordinates: [oldLocation,newLocation.coordinate], count: 2)
            mapPlane.addOverlay(polyline)
            oldLocation = newLocation.coordinate
        }
        planeAnnotation.coordinate = oldLocation
    }
    
    // MARK: - IBAction
    @IBAction func onBtnBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MKMAPViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            return renderer
        } else {
            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 2
                return renderer
            }
        }
        return MKTileOverlayRenderer()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationPointAnnotation) {
            return nil
        }
        let reuseId = "LocationPin"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = annotation
        }

        let cpa = annotation as! LocationPointAnnotation
        if cpa.imageName != nil{
            anView?.image = UIImage(named:cpa.imageName)
        }
        return anView
    }
    
}
