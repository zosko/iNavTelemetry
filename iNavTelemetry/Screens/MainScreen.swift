//
//  ViewController.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/28/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toast
import MapKit
import CoreBluetooth

class MainScreen: UIViewController {

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
    @IBOutlet var imgHorizontPlane: UIImageView!
    @IBOutlet var imgHorizontLine: UIImageView!
    
    //MARK: - Variables
    var planeAnnotation : LocationPointAnnotation!
    var gsAnnotation : LocationPointAnnotation!
    var telemetry = SmartPort()
    var locationManager:CLLocationManager?
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var peripherals : [CBPeripheral] = []
    var oldLocation : CLLocationCoordinate2D!
    
    //MARK: - IBActions
    @IBAction func onBtnConnect(_ sender: Any) {
        if connectedPeripheral != nil {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
            connectedPeripheral = nil;
            peripherals.removeAll()
        }
        else{
            peripherals.removeAll()
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")], options: nil)
            MBProgressHUD.showAdded(to: self.view, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.stopSearchReader()
            }
        }
    }
    @IBAction func onBtnSetHomePosition(_ sender: Any){
        gsAnnotation.coordinate = planeAnnotation.coordinate
        oldLocation = gsAnnotation.coordinate
        let region = MKCoordinateRegion(center: gsAnnotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapPlane.setRegion(region, animated: true)
    }
    
    //MARK: - CustomFunctions
    func addAnnotations(){
        planeAnnotation = LocationPointAnnotation()
        planeAnnotation.title = "Plane"
        planeAnnotation.imageName = "plane"
        
        gsAnnotation = LocationPointAnnotation()
        gsAnnotation.title = "Ground Station"
        gsAnnotation.imageName = "gs"
        mapPlane.addAnnotations([gsAnnotation,planeAnnotation])
    }
    func getStabilization(telemetry: SmartPortStruct) -> String{
        let mode = telemetry.flight_mode / 10 % 10
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
    func getArmed(telemetry: SmartPortStruct) -> String{
        let mode = telemetry.flight_mode % 10
        if mode == 5{
            return "YES"
        }
        return "NO"
    }
    func refreshTelemetry(telemetry: SmartPortStruct){
        lblLatitude.text = "Latitude\n \(telemetry.lat)"
        lblLongitude.text = "Longitude\n \(telemetry.lng)"
        lblSatellites.text = "Satellites\n \(telemetry.gps_sats)"
        lblDistance.text = "Distance\n \(telemetry.distance) m"
        lblAltitude.text = "Altitude\n \(telemetry.alt) m"
        lblSpeed.text = "Speed\n \(telemetry.speed) km/h"
        lblVoltage.text = "Voltage\n \(telemetry.voltage) V"
        lblCurrent.text = "Current\n \(telemetry.current) Amp"
        lblStabilization.text = "Flymode\n \(getStabilization(telemetry: telemetry))"
        lblArmed.text = "Armed\n \(getArmed(telemetry: telemetry))"
        lblSignalStrength.text = "Signal\n \(telemetry.rssi) %"
        lblFuel.text = "Fuel\n \(telemetry.fuel) %"
        
        refreshLocation(latitude: telemetry.lat, longitude: telemetry.lng)
        refreshCompass(degree: telemetry.heading)
        refreshHorizon(pitch: -telemetry.pitch, roll: telemetry.roll)
    }
    
    func refreshCompass(degree: Int){
        imgCompass.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(degree) / 180.0))
    }
    func refreshHorizon(pitch: Int, roll: Int){
        imgHorizontPlane.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(roll) / 180.0))
        imgHorizontLine.frame.origin.y = CGFloat(pitch)
    }
    func refreshLocation(latitude: Double, longitude: Double){
        let location = CLLocation(latitude: latitude, longitude: longitude)
        planeAnnotation.coordinate = location.coordinate
        
        let polyline = MKPolyline(coordinates: [oldLocation,planeAnnotation.coordinate], count: 2)
        mapPlane.addOverlay(polyline)
        oldLocation = planeAnnotation.coordinate
    }
    func stopSearchReader(){
        centralManager.stopScan()
        
        let alert = UIAlertController.init(title: "Search device", message: "Choose Tracker device", preferredStyle: .actionSheet)
        
        for periperal in peripherals{
            let action = UIAlertAction.init(title: periperal.name ?? "no_name", style: .default) { (action) in
                self.centralManager.connect(periperal, options: nil)
            }
            alert.addAction(action)
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .destructive) { (action) in
        }
        alert.addAction(actionCancel)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = btnConnect;
            presenter.sourceRect = btnConnect.bounds;
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIViewDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        addAnnotations()
        
        let urlTeplate = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: urlTeplate)
        overlay.canReplaceMapContent = true
        mapPlane.addOverlay(overlay, level: .aboveLabels)
    }
}

