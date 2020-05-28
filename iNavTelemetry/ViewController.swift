//
//  ViewController.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/28/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import MapKit
import CoreBluetooth
import MBProgressHUD
import Toast

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
    var heading = 0
    var flight_mode = 0
    var fuel = 0
    var roll = 0
    var pitch = 0
    
    init(){
        
    }
}

class ViewController: UIViewController,MKMapViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate {

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
    var packetTelemetry = TrackerStruct()
    var locationManager:CLLocationManager?
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var peripherals : [CBPeripheral] = []
    var rcv_buffer : [UInt8] = [UInt8](repeating: 0, count: 200)
    var buffer_index : Int = 0
    var found_header : Bool = false
    var rcv_length : UInt8 = 0
    
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
        let locationGS = CLLocation(latitude: packetTelemetry.lat+0.001, longitude: packetTelemetry.lng+0.001)
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
        let START_FLAG : UInt8 = 0xFE
        let END_FLAG : UInt8 = 0x7F
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

        packetTelemetry.heading = Int(buffer_get_int16(buffer: payload, index:ind))
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
        refreshCompass(degree: packetTelemetry.heading)
        refreshHorizon(pitch: -packetTelemetry.pitch, roll: packetTelemetry.roll)
    }
    
    func refreshCompass(degree: Int){
        imgCompass.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(degree) / 180.0))
    }
    func refreshHorizon(pitch: Int, roll: Int){
        imgHorizontPlane.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * Double(roll) / 180.0))
        imgHorizontLine.frame.origin.y = CGFloat(pitch)
    }
    func refreshLocation(latitude: Double, longitude: Double){
        if((planeAnnotation) != nil){
            mapPlane.removeAnnotation(planeAnnotation)
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        planeAnnotation = LocationPointAnnotation()
        planeAnnotation.coordinate = location.coordinate
        planeAnnotation.title = "Plane"
        planeAnnotation.imageName = "plane"
        mapPlane.addAnnotation(planeAnnotation)
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
    
    //MARK: CentralManagerDelegates
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var message = "Bluetooth"
        switch (central.state) {
        case .unknown: message = "Bluetooth Unknown."; break
        case .resetting: message = "The update is being started. Please wait until Bluetooth is ready."; break
        case .unsupported: message = "This device does not support Bluetooth low energy."; break
        case .unauthorized: message = "This app is not authorized to use Bluetooth low energy."; break
        case .poweredOff: message = "You must turn on Bluetooth in Settings in order to use the reader."; break
        default: break;
        }
        print("Bluetooth: " + message);
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral){
            peripherals.append(peripheral)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral.delegate = self
        connectedPeripheral.discoverServices([CBUUID (string: "FFE0")])
        self.view.makeToast("Connected to tracker")
        btnConnect.setImage(UIImage(named: "power_on"), for: .normal)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("FailToConnect" + error!.localizedDescription)
        }
        self.view.makeToast("Fail to connect to tracker")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("FailToDisconnect" + error!.localizedDescription)
            
            centralManager.cancelPeripheralConnection(connectedPeripheral)
            connectedPeripheral = nil;
            peripherals.removeAll()
            return
        }
        self.view.makeToast("Disconnected from tracker")
        btnConnect.setImage(UIImage(named: "power_off"), for: .normal)
    }
    
    //MARK: PeripheralDelegates
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving didWriteValueFor \(characteristic) : " + error!.localizedDescription)
            return
        }
    }
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving notification for characteristic \(characteristic) : " + error!.localizedDescription)
            return
        }
        process_incoming_bytes(incomingData: characteristic.value!)
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            peripheral.discoverCharacteristics([CBUUID (string: "FFE1")], for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving didUpdateNotificationStateFor \(characteristic) : " + error!.localizedDescription)
            return
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == CBUUID(string: "FFE1"){
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
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
        
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        
        let urlTeplate = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: urlTeplate)
        overlay.canReplaceMapContent = true
        mapPlane.addOverlay(overlay, level: .aboveLabels)
        
    }
}

