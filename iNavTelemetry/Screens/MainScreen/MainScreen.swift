//
//  ViewController.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/28/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import MBProgressHUD
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
    @IBOutlet var lblFlyTime: UILabel!
    @IBOutlet var lblOnlineUsers: UILabel!
    
    //MARK: - Variables
    var planeAnnotation : LocationPointAnnotation!
    var gsAnnotation : LocationPointAnnotation!
    var telemetry = Telemetry()
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var peripherals : [CBPeripheral] = []
    var oldLocation : CLLocationCoordinate2D!
    var currentTime = 0.0
    var seconds = 0
    var fixHomePosition = false
    
    //MARK: - IBActions
    @IBAction func onBtnConnect(_ sender: Any) {
        fixHomePosition = false
        
        if connectedPeripheral != nil {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
            connectedPeripheral = nil;
            peripherals.removeAll()
        }
        else{
            peripherals.removeAll()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            MBProgressHUD.showAdded(to: self.view, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.stopSearchReader()
            }
        }
    }
    @IBAction func onBtnLogs(_ sender : Any){
        let alert = UIAlertController.init(title: "FLIGHT LOGS", message: "", preferredStyle: .actionSheet)
        
        for log in Database.shared.getLogs(){
            let action = UIAlertAction.init(title: toDate(timestamp: Double(log.pathComponents.last!)!), style: .default) { (action) in
                self.openLog(urlLog: log)
            }
            alert.addAction(action)
        }
        
        if Database.shared.getLogs().count > 0 {
            let action = UIAlertAction.init(title: "Clean Database", style: .destructive) { (action) in
                Database.shared.cleanDatabase()
            }
            alert.addAction(action)
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(actionCancel)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = btnConnect;
            presenter.sourceRect = btnConnect.bounds;
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CustomFunctions
    func addHomePosition(){
        if planeAnnotation.coordinate.latitude != CLLocationCoordinate2D(latitude: 0, longitude: 0).latitude {
            fixHomePosition = true
            
            Database.shared.startLogging()
            
            gsAnnotation.coordinate = planeAnnotation.coordinate
            let region = MKCoordinateRegion(center: gsAnnotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapPlane.setRegion(region, animated: true)
            
            oldLocation = gsAnnotation.coordinate
        }
    }
    func addSocketListeners(){
        SocketComunicator.shared.planesLocation { (planes) in
            let annotations = self.mapPlane.annotations as! [LocationPointAnnotation]
            let annotationsToRemove = annotations.filter { $0.imageName == "other_plane" || $0.imageName == "airport"  }
            self.mapPlane.removeAnnotations(annotationsToRemove)
            
            for plane in planes {
                let location = CLLocation(latitude: plane.lat, longitude: plane.lng)
                let otherPlane = LocationPointAnnotation()
                otherPlane.title = plane.name
                otherPlane.imageName = plane.type == .airport ? "airport" : "other_plane"
                otherPlane.coordinate = location.coordinate
                self.mapPlane.addAnnotation(otherPlane)
            }
            
            let onlineUsers = planes.filter{ $0.type == .plane }.count
            self.lblOnlineUsers.text = "Online\n \(onlineUsers)"
        }
    }
    func addAnnotations(){
        planeAnnotation = LocationPointAnnotation()
        planeAnnotation.title = "My Plane"
        planeAnnotation.imageName = "my_plane"
        
        gsAnnotation = LocationPointAnnotation()
        gsAnnotation.title = "Ground Station"
        gsAnnotation.imageName = "gs"
        mapPlane.addAnnotations([gsAnnotation,planeAnnotation])
    }
    func refreshTelemetry(packet: TelemetryStruct){
        lblLatitude.text = "Latitude\n \(packet.lat)"
        lblLongitude.text = "Longitude\n \(packet.lng)"
        lblSatellites.text = "Satellites\n \(packet.gps_sats)"
        lblDistance.text = "Distance\n \(packet.distance) m"
        lblAltitude.text = "Altitude\n \(packet.alt) m"
        lblSpeed.text = "Speed\n \(packet.speed) km/h"
        lblVoltage.text = "Voltage\n \(packet.voltage) V"
        lblCurrent.text = "Current\n \(packet.current) Amp"
        lblStabilization.text = "Flymode\n \(telemetry.getStabilization())"
        lblArmed.text = "Armed\n \(telemetry.getArmed())"
        lblSignalStrength.text = "Signal\n \(packet.rssi) %"
        lblFuel.text = "Fuel\n \(packet.fuel) %"
        lblFlyTime.text = String(format:"%02ld:%02ld:%02ld", seconds / 3600, (seconds / 60) % 60, seconds % 60)
        
        refreshLocation(latitude: packet.lat, longitude: packet.lng)
        refreshCompass(degree: packet.heading)
        refreshHorizon(pitch: -packet.pitch, roll: packet.roll)
        
        if packet.gps_sats > 5 && !fixHomePosition{
            addHomePosition()
        }
        
        if Date().timeIntervalSince1970 - currentTime > 1 && Database.shared.active { // send/save data every second
            seconds += 1
            
            SocketComunicator.shared.sendPlaneData(packet: packet)
            
            Database.shared.saveTelemetryData(packet: packet)
            currentTime = Date().timeIntervalSince1970
        }
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
        
        guard let tmpOldLocation = oldLocation else { return }
        let polyline = MKPolyline(coordinates: [tmpOldLocation,planeAnnotation.coordinate], count: 2)
        mapPlane.addOverlay(polyline)
        oldLocation = planeAnnotation.coordinate
    }
    func stopSearchReader(){
        centralManager.stopScan()
        
        let alert = UIAlertController.init(title: "Search device", message: "Choose Tracker device", preferredStyle: .actionSheet)
        
        for periperal in peripherals{
            let action = UIAlertAction.init(title: periperal.name ?? "missing name", style: .default) { (action) in
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
        addSocketListeners()
    }
}

