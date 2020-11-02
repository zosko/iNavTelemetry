//
//  LogScreen.swift
//  iNavTelemetryOSX
//
//  Created by Bosko Petreski on 11/2/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import Cocoa
import MapKit

class LogScreen: NSViewController, MKMapViewDelegate {
    
    // MARK: Public Variable
    public var logData : [SmartPortStruct] = []
    
    //MARK: - IBoutlets
    @IBOutlet var mapPlane : MKMapView!
    
    //MARK: - Variables
    var planeAnnotation : LocationPointAnnotation!
    var gsAnnotation : LocationPointAnnotation!
    var oldLocation : CLLocationCoordinate2D!

    // MARK: - IBActions
    @IBAction func onBtnBack(_ sender : NSButton){
        self.dismiss(self)
    }
    
    // MARK: - NSViewDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        planeAnnotation = LocationPointAnnotation()
        planeAnnotation.title = "My Plane"
        planeAnnotation.imageName = "my_plane"
        
        gsAnnotation = LocationPointAnnotation()
        gsAnnotation.title = "Ground Station"
        gsAnnotation.imageName = "gs"
        mapPlane.addAnnotations([gsAnnotation,planeAnnotation])

        let location = CLLocation(latitude: logData.first!.lat, longitude: logData.first!.lng)
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
    
    // MARK: - MAPViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            return renderer
        } else {
            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = NSColor.red
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
            anView?.image = NSImage(named:cpa.imageName)
        }
        return anView
    }
}
