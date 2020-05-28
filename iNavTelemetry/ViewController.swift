//
//  ViewController.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/28/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import MapKit

struct TrackerStruct {
    var lat = 0.0
    var lng = 0.0
    var alt = 0
    var gps_sats = 0
    var distance = 0
    var speed = 0
    var voltage = 0.0
    var rssi = 0
    var current = 0
    var heading = 0.0
    var flight_mode = 0
    var fuel = 0
    var roll = 0
    var pitch = 0
    
    init(){
        
    }
}

class ViewController: UIViewController,MKMapViewDelegate {

    // MARK: IBOutlets
    @IBOutlet var mapPlane : MKMapView!
    @IBOutlet var btnConnect : UIButton!
    @IBOutlet var lblLatitude: UILabel!
    @IBOutlet var lblLongitude: UILabel!
    @IBOutlet var lblSatellites: UILabel!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblAltitude: UILabel!
    @IBOutlet var lblSpeed: UILabel!
    @IBOutlet var lblVoltage: UILabel!
    @IBOutlet var lblCurrent: UILabel!
    @IBOutlet var lblArmed: UILabel!
    @IBOutlet var lblStabilization: UILabel!
    @IBOutlet var lblSignalStrength: UILabel!
    @IBOutlet var lblFuel: UILabel!
    @IBOutlet var imgCompass: UIImageView!
    @IBOutlet var imgHorizont: UIImageView!
    
    //MARK: - Variables
    var packetTelemetry = TrackerStruct()
    
    //MARK: - IBActions
    @IBAction func onBtnConnect(_ sender: Any) {
        
    }
    @IBAction func onBtnSetHomePosition(_ sender: Any){
        let locationGS = CLLocation(latitude: packetTelemetry.lat, longitude: packetTelemetry.lng)
        let region = MKCoordinateRegion(center: locationGS.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapPlane.setRegion(region, animated: true)
        
        let annotation = LocationPointAnnotation()
        annotation.coordinate = locationGS.coordinate
        annotation.title = "Ground Station"
        annotation.imageName = "gs"
        mapPlane.addAnnotation(annotation)
    }
    
    //MARK: - Telemetry Functions
    func process_incoming_bytes(incomingData: Data){
        let bytes: [UInt8] = incomingData.map{ $0 }
        var rcv_buffer : [UInt8] = [UInt8](repeating: 0, count: 200)
        let START_FLAG : UInt8 = 0xFE
        let END_FLAG : UInt8 = 0x7F
        var buffer_index : Int = 0
        var found_header : Bool = false
        var rcv_length : UInt8 = 0
        var packetReceived = false
        
        var checksum : UInt8 = 0
        
        for i in 0 ..< bytes.count {
            if(bytes[i] == START_FLAG){
                found_header = true
                buffer_index = 0
                rcv_length = 0
            }
            else if(bytes[i] == END_FLAG){
                
                if (buffer_index >= 2 && (buffer_index - 1) == rcv_length){
                    checksum = rcv_length
                    
                    for i in 0 ..< rcv_length {
                        checksum ^= rcv_buffer[Int(i)];
                        
                        if (checksum == rcv_buffer[buffer_index - 1]){
                            // Packet is good
                            rcv_length = 0
                            buffer_index = 0
                            found_header = false
                            packetReceived = true
                            break;
                        }
                    }
                    break;
                }
            }
            else if (found_header && rcv_length == 0){
                rcv_length = bytes[i]
            }
            else if (found_header && rcv_length > 10) {
                rcv_buffer[buffer_index] = bytes[i]
                buffer_index += 1
            }
        }
        
        if(packetReceived){
            readPacket(payload: rcv_buffer)
        }
    }
    func buffer_get_int16(buffer: [UInt8], index : Int) -> UInt16{
        return UInt16(buffer[index]) << 8 | UInt16(buffer[index + 1])
    }
    func buffer_get_int32(buffer: [UInt8], index : Int) -> UInt32 {
        return UInt32(buffer[index]) << 24 | UInt32(buffer[index + 1]) << 16 | UInt32(buffer[index + 2]) << 8 | UInt32(buffer[index + 3])
    }
    func buffer_get_float16(buffer: [UInt8], scale : Double, index : Int) -> Double{
        return Double(buffer_get_int16(buffer: buffer, index: index)) / scale
    }
    func buffer_get_float32(buffer: [UInt8], scale : Double, index : Int) -> Double{
        return (Double)(buffer_get_int32(buffer: buffer, index: index)) / scale
    }
    func linearInterpolation(inVal:Double, inMin:Double, inMax:Double, outMin:Double, outMax:Double) -> Double{
        if (inMin == 0 && inMax == 0) {
            return 0.0;
        }
        return (inVal - inMin) / (inMax - inMin) * (outMax - outMin) + outMin;
    }
    func readPacket(payload : [UInt8]){
        var ind : Int = 0

        packetTelemetry.lat = buffer_get_float32(buffer: payload, scale:1e7, index:ind)
        ind += 4

        packetTelemetry.lng = buffer_get_float32(buffer: payload, scale:1e7, index:ind)
        ind += 4

        packetTelemetry.alt = Int(buffer_get_int16(buffer: payload, index:ind))
        ind += 2

        packetTelemetry.gps_sats = Int(payload[ind])
        ind += 1

        packetTelemetry.distance = Int(buffer_get_int16(buffer: payload, index:ind))
        ind += 2

        packetTelemetry.speed = Int(payload[ind])
        ind += 1

        packetTelemetry.voltage = buffer_get_float16(buffer: payload, scale:1e2, index:ind)
        ind += 2

        packetTelemetry.rssi = Int(payload[ind])
        ind += 1

        packetTelemetry.current = Int(payload[ind])
        ind += 1

        packetTelemetry.heading = buffer_get_float16(buffer: payload, scale:1e0, index:ind)
        ind += 2
        
        packetTelemetry.flight_mode = Int(payload[ind])
        ind += 1
        
        packetTelemetry.fuel = Int(payload[ind])
        ind += 1
        
        packetTelemetry.pitch = Int(linearInterpolation(inVal: Double(payload[ind]), inMin: 0, inMax: 200, outMin: -100, outMax: 100))
        ind += 1
        
        packetTelemetry.roll = Int(linearInterpolation(inVal: Double(payload[ind]), inMin: 0, inMax: 200, outMin: -100, outMax: 100))
        ind += 1

        refreshTelemetry()
    }
    
    //MARK: - CustomFunctions
    func getStabilization() -> String{
        let mode = packetTelemetry.flight_mode / 10 % 10
        if mode == 2{
            return "horizon"
        }
        else if mode == 1 {
            return "angle"
        }
        else{
            return "manual"
        }
    }
    func getArmed() -> String{
        let mode = packetTelemetry.flight_mode % 10
        if mode == 5{
            return "YES"
        }
        return "NO"
    }
    func refreshTelemetry(){
        print(packetTelemetry)
        
        lblLatitude.text = "Latitude\n \(packetTelemetry.lat)"
        lblLongitude.text = "Longitude\n \(packetTelemetry.lng)"
        lblSatellites.text = "Satellites\n \(packetTelemetry.gps_sats)"
        lblDistance.text = "Distance\n \(packetTelemetry.distance) m"
        lblAltitude.text = "Altitude\n \(packetTelemetry.alt) m"
        lblSpeed.text = "Speed\n \(packetTelemetry.speed) km/h"
        lblVoltage.text = "Voltage\n \(packetTelemetry.voltage) V"
        lblCurrent.text = "Current\n \(packetTelemetry.current) Amp"
        lblStabilization.text = "Stabilization\n \(getStabilization())"
        lblArmed.text = "Armed\n \(getArmed())"
        lblSignalStrength.text = "Signal\n \(packetTelemetry.rssi) %"
        lblFuel.text = "Fuel\n \(packetTelemetry.fuel) %"
        
        refreshLocation(latitude: packetTelemetry.lat, longitude: packetTelemetry.lng)
        refreshCompass(degree: CGFloat(-packetTelemetry.heading))
        refreshHorizon(pitch: CGFloat(packetTelemetry.pitch), roll: CGFloat(-packetTelemetry.roll))
    }
    
    func refreshCompass(degree: CGFloat){
        imgCompass.transform = CGAffineTransform(rotationAngle: degree)
    }
    func refreshHorizon(pitch: CGFloat, roll: CGFloat){
        imgHorizont.transform = CGAffineTransform(rotationAngle: roll)
    }
    func refreshLocation(latitude: Double, longitude: Double){
        mapPlane.removeAnnotations(mapPlane.annotations)
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let annotation = LocationPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Plane"
        annotation.imageName = "plane"
        mapPlane.addAnnotation(annotation)
    }
    
    // MARK: - MAPViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            return renderer
        } else {
            return MKTileOverlayRenderer()
        }
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
    
    // MARK: - UIViewDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlTeplate = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: urlTeplate)
        overlay.canReplaceMapContent = true
        mapPlane.addOverlay(overlay, level: .aboveLabels)
        
    }
}

