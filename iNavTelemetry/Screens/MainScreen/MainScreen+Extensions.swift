//
//  MainScreen+Extensions.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import CocoaAsyncSocket

extension MainScreen : GCDAsyncSocketDelegate {
    //MARK: - GCDAsyncSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        socket.readData(withTimeout: -1, tag: 0)
        if telemetry.process_incoming_bytes(incomingData: data) {
            refreshTelemetry(packet: telemetry.packet)
        }
    }
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        btnConnect.setImage(UIImage(named: "power_off"), for: .normal)
        Database.shared.stopLogging()
        self.showMessage(message: "Disconnected")
    }
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        socket.readData(withTimeout: -1, tag: 0)
        btnConnect.setImage(UIImage(named: "power_on"), for: .normal)
        self.showMessage(message: "Connected")
    }
}

extension MainScreen : MKMapViewDelegate{
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

extension MainScreen {
    // MARK: - Helpers
    func toDate(timestamp : Double) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM d [hh:mm]"
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
    func openLog(urlLog : URL){
        let jsonData = try! Data(contentsOf: urlLog)
        let logData = try! JSONDecoder().decode([SmartPortStruct].self, from: jsonData)
        
        let controller : LogScreen = self.storyboard!.instantiateViewController(withIdentifier: "LogScreen") as! LogScreen
        controller.logData = logData
        self.present(controller, animated: true, completion: nil)
    }
    func showMessage(message : String){
        let messageHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        messageHUD.mode = .text
        messageHUD.label.text = message
        messageHUD.hide(animated: true, afterDelay: 2)
    }
}
