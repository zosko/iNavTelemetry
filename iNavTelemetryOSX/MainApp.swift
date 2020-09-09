//
//  ViewController.swift
//  iNavTelemetryOSX
//
//  Created by Bosko Petreski on 9/8/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import Cocoa
import ORSSerial
import MapKit
import AVFoundation

class MainApp: NSViewController,ORSSerialPortDelegate,MKMapViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet var popupPorts : NSPopUpButton!
    @IBOutlet var popupVideoInput : NSPopUpButton!
    @IBOutlet var mapPlane : MKMapView!
    @IBOutlet var btnConnect : NSButton!
    @IBOutlet var lblLatitude: NSTextField!
    @IBOutlet var lblLongitude: NSTextField!
    @IBOutlet var lblSatellites: NSTextField!
    @IBOutlet var lblDistance: NSTextField!
    @IBOutlet var lblAltitude: NSTextField!
    @IBOutlet var lblSpeed: NSTextField!
    @IBOutlet var lblVoltage: NSTextField!
    @IBOutlet var lblCurrent: NSTextField!
    @IBOutlet var lblArmed: NSTextField!
    @IBOutlet var lblStabilization: NSTextField!
    @IBOutlet var lblSignalStrength: NSTextField!
    @IBOutlet var lblFuel: NSTextField!
    @IBOutlet var imgCompass: NSImageView!
    @IBOutlet var imgHorizont: NSImageView!
    @IBOutlet var viewCockpit: NSView?
    
    //MARK: - Variables
    let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .video, position: .unspecified).devices
    let session: AVCaptureSession = AVCaptureSession()
    var planeAnnotation : LocationPointAnnotation!
    var gsAnnotation : LocationPointAnnotation!
    let serialPortManager = ORSSerialPortManager.shared()
    var serialPort: ORSSerialPort?
    var telemetry = SmartPort()
    var oldLocation : CLLocationCoordinate2D!
    
    //MARK: - IBActions
    @IBAction func onBtnConnect(_ sender: Any) {
        if((serialPort?.isOpen) != nil){
            serialPort?.close()
        }
        else{
            serialPort = ORSSerialPort(path: "/dev/tty."+popupPorts.selectedItem!.title)
            serialPort?.baudRate = 57600
            serialPort?.delegate = self
            serialPort?.open()
        }
    }
    @IBAction func onBtnSetHomePosition(_ sender: Any){
        gsAnnotation.coordinate = planeAnnotation.coordinate
        oldLocation = gsAnnotation.coordinate
        let region = MKCoordinateRegion(center: gsAnnotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapPlane.setRegion(region, animated: true)
    }
    @IBAction func onVideoChoose(_ sender: NSPopUpButton){
        let device = videoDevices[popupVideoInput.indexOfSelectedItem]
        let input = try! AVCaptureDeviceInput(device: device)

        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        viewCockpit?.wantsLayer = true
        session.sessionPreset = AVCaptureSession.Preset.low
        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewCockpit!.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        viewCockpit?.layer?.addSublayer(previewLayer)
        session.startRunning()
        popupVideoInput.isHidden = true
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
    func refreshTelemetry(packet: SmartPortStruct){
        lblLatitude.stringValue = "Latitude\n \(packet.lat)"
        lblLongitude.stringValue = "Longitude\n \(packet.lng)"
        lblSatellites.stringValue = "Satellites\n \(packet.gps_sats)"
        lblDistance.stringValue = "Distance\n \(packet.distance) m"
        lblAltitude.stringValue = "Altitude\n \(packet.alt) m"
        lblSpeed.stringValue = "Speed\n \(packet.speed) km/h"
        lblVoltage.stringValue = "Voltage\n \(packet.voltage) V"
        lblCurrent.stringValue = "Current\n \(packet.current) Amp"
        lblStabilization.stringValue = "Stabilization\n \(telemetry.getStabilization())"
        lblArmed.stringValue = "Armed\n \(telemetry.getArmed())"
        lblSignalStrength.stringValue = "Signal\n \(packet.rssi) %"
        lblFuel.stringValue = "Fuel\n \(packet.fuel) %"
        
        refreshLocation(latitude: packet.lat, longitude: packet.lng)
        refreshCompass(degree: CGFloat(-packet.heading))
        refreshHorizon(pitch: CGFloat(packet.pitch), roll: CGFloat(-packet.roll))
    }
    
    func refreshCompass(degree: CGFloat){
        DispatchQueue.main.async {
            self.imgCompass.frameCenterRotation = degree
        }
    }
    func refreshHorizon(pitch: CGFloat, roll: CGFloat){
        DispatchQueue.main.async {
            self.imgHorizont.frameCenterRotation = roll
        }
    }
    func refreshLocation(latitude: Double, longitude: Double){
        let location = CLLocation(latitude: latitude, longitude: longitude)
        planeAnnotation.coordinate = location.coordinate
        
        guard let tmpOldLocation = oldLocation else { return }
        let polyline = MKPolyline(coordinates: [tmpOldLocation,planeAnnotation.coordinate], count: 2)
        mapPlane.addOverlay(polyline)
        oldLocation = planeAnnotation.coordinate
    }
    
    // MARK: - ORSSerialPortDelegate
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        btnConnect.image = NSImage(named: "power_on")
        popupPorts.isHidden = true
    }
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        btnConnect.image = NSImage(named: "power_off")
    }
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if telemetry.process_incoming_bytes(incomingData: data) {
            refreshTelemetry(packet: telemetry.packet)
        }
    }
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("serialPortWasRemovedFromSystem")
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
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
    
    // MARK: - UIViewDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let urlTeplate = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
//        let overlay = MKTileOverlay(urlTemplate: urlTeplate)
//        overlay.canReplaceMapContent = true
//        mapPlane.addOverlay(overlay, level: .aboveLabels)
        
        addAnnotations()
        
        let availablePorts = serialPortManager.availablePorts
        for port in availablePorts {
            popupPorts.addItem(withTitle: port.name)
        }
        
        for device in videoDevices {
            self.popupVideoInput.addItem(withTitle: device.localizedName)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

