//
//  ViewController.swift
//  iNavTelemetryOSX
//
//  Created by Bosko Petreski on 9/8/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import Cocoa
import MapKit
import AVFoundation
import CoreBluetooth

class MainApp: NSViewController,AVCapturePhotoCaptureDelegate {
    
    // MARK: IBOutlets
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
    @IBOutlet var switchLive : NSSwitch!
    
    //MARK: - Variables
    let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .video, position: .unspecified).devices
    let session: AVCaptureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var planeAnnotation : LocationPointAnnotation!
    var gsAnnotation : LocationPointAnnotation!
    var telemetry = SmartPort()
    var oldLocation : CLLocationCoordinate2D!
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var peripherals : [CBPeripheral] = []
    var tempCapturePhotoCamera : String = ""
    
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
            
            showProgress()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.stopSearchReader()
            }
        }
    }
    @IBAction func onBtnSetHomePosition(_ sender: Any){
        if planeAnnotation.coordinate.latitude != CLLocationCoordinate2D(latitude: 0, longitude: 0).latitude {
            gsAnnotation.coordinate = planeAnnotation.coordinate
            let region = MKCoordinateRegion(center: gsAnnotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapPlane.setRegion(region, animated: true)
        }
    }
    @IBAction func onVideoChoose(_ sender: NSPopUpButton){
        let device = videoDevices[popupVideoInput.indexOfSelectedItem]
        let input = try! AVCaptureDeviceInput(device: device)

        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
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
    func capturePhoto(){
        if session.isRunning {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    func showProgress(){
        let bgView = NSView(frame: self.view.frame)
        bgView.wantsLayer = true
        bgView.layer?.backgroundColor = NSColor.white.cgColor
        bgView.layer?.opacity = 0.7
        
        let label = NSTextView(frame: NSRect(x: 0, y: 300, width: bgView.frame.size.width, height: 300))
        label.string = "Searching for device"
        label.textColor = NSColor.black
        label.alignment = .center
        label.font = NSFont.labelFont(ofSize: 40)
        bgView.addSubview(label)
        
        self.view.addSubview(bgView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            bgView.removeFromSuperview()
        }
    }
    func addSocketListeners(){
        SocketComunicator.shared.planesLocation { (data) in
            let annotations = self.mapPlane.annotations as! [LocationPointAnnotation]
            let annotationsToRemove = annotations.filter { $0.imageName == "other_plane" }
            self.mapPlane.removeAnnotations(annotationsToRemove)
            
            for (key,planeData) in data {
                let object = planeData as! [String:Any]
                let lat = CLLocationDegrees(object["lat"] as! Double)
                let lng = CLLocationDegrees(object["lng"] as! Double)
                
                let location = CLLocation(latitude: lat, longitude: lng)
                let otherPlane = LocationPointAnnotation()
                otherPlane.title = key
                otherPlane.imageName = "other_plane"
                otherPlane.coordinate = location.coordinate
                self.mapPlane.addAnnotation(otherPlane)
            }
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
        
        if switchLive.state == .on {
            capturePhoto()
            SocketComunicator.shared.sendPlaneData(packet: packet, photo: tempCapturePhotoCamera)
        }
        
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
    func stopSearchReader(){
        centralManager.stopScan()
        
        let alert = NSAlert()
        alert.messageText = "Select Smart Port device"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Cancel")
        
        for periperal in peripherals{
            alert.addButton(withTitle: periperal.name ?? "no_name")
        }
        
        alert.beginSheetModal(for: self.view.window!) { (response) in
            if response != .alertFirstButtonReturn {
                let deviceIndex = response.rawValue - 1001 // to get index 0.1.2...
                print("selected device: \(deviceIndex)")
                self.centralManager.connect(self.peripherals[deviceIndex], options: nil)
            }
        }
    }
    
    // MARK: - CapturePhoto
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        if let data = imageData {
            tempCapturePhotoCamera = data.base64EncodedString()
        }
    }
    
    // MARK: - UIViewDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let urlTeplate = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
//        let overlay = MKTileOverlay(urlTemplate: urlTeplate)
//        overlay.canReplaceMapContent = true
//        mapPlane.addOverlay(overlay, level: .aboveLabels)
        
        addAnnotations()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        
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

