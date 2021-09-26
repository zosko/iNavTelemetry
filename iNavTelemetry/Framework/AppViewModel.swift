//
//  ConnectionViewModel.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/7/21.
//

import Foundation
import Combine
import SwiftUI
import CoreBluetooth
import MapKit

struct Plane: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let mine: Bool
}

class AppViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var selectedProtocol: TelemetryManager.TelemetryType = TelemetryManager.TelemetryType.smartPort
    @Published var connected = false
    @Published var homePositionAdded = false
    @Published var mineLocation = [Plane(id: "", coordinate: .init(), mine: true)]
    @Published var allPlanes = [Plane(id: "", coordinate: .init(), mine: false)]
    @Published var peripherals : [CBPeripheral] = []
    @Published var telemetry = TelemetryManager.InstrumentTelemetry(packet: TelemetryManager.Packet(),
                                                                    telemetryType: .smartPort,
                                                                    seconds: 0)
    var logsData: [URL] { database.getLogs() }
    var showListLogs = false
    var showPeripherals = false
    
    @ObservedObject private var bluetoothManager = BluetoothManager()
    @ObservedObject private var socketCommunicator = SocketComunicator()
    
    private var database = Database()
    private var cancellable: [AnyCancellable] = []
    private var telemetryManager = TelemetryManager()
    private var timerRequestMSP: Timer?
    private var timerFlying: Timer?
    private var seconds = 0
    
    override init(){
        super.init()
        self.region.span = MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
        
        Publishers.CombineLatest(socketCommunicator.$planes, $mineLocation)
            .map{
                return $0.0 + $0.1
            }
            .assign(to: &$allPlanes)
        
        $selectedProtocol.sink {
            self.telemetryManager.chooseTelemetry(type: $0)
        }.store(in: &cancellable)
        
        bluetoothManager.$dataReceived.sink { [unowned self] data in
            guard self.telemetryManager.parse(incomingData: data) else {
                return
            }
            self.telemetry = self.telemetryManager.telemetry
            
            if (self.telemetry.packet.gps_sats > 5 && !self.homePositionAdded) {
                self.showHomePosition(location: self.telemetry.location)
            }
            
            self.updateLocation(location: self.telemetry.location)
            
            let logTelemetry = TelemetryManager.LogTelemetry(lat: self.telemetry.location.latitude,
                                                             lng: self.telemetry.location.longitude)
            
            if self.homePositionAdded {
                socketCommunicator.sendPlaneData(location: logTelemetry)
                database.saveTelemetryData(packet: logTelemetry)
            }
        }.store(in: &cancellable)
        
        bluetoothManager.$peripheralFound.sink { [unowned self] peripheral in
            guard let device = peripheral, let _ = device.name else { return }
            
            if !self.peripherals.contains(device) {
                self.peripherals.append(device)
                self.showPeripherals = self.peripherals.count > 0
            }
        }.store(in: &cancellable)
        
        bluetoothManager.$connected.sink { [unowned self] connected in
            self.connected = connected
            
            if connected {
                self.homePositionAdded = false
                self.seconds = 0
                database.startLogging()
                timerFlying = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                    self.seconds += 1
                    self.telemetryManager.flyingTime(seconds: self.seconds)
                }
            }
            else{
                if self.homePositionAdded {
                    database.stopLogging()
                }
                self.homePositionAdded = false
                timerFlying?.invalidate()
                timerFlying = nil
                
            }
            
            if self.telemetryManager.telemetryType == .msp {
                self.MSPTelemetry(start: connected)
            }
        }.store(in: &cancellable)
    }
    
    //MARK: Internal functions
    func showHomePosition(location: CLLocationCoordinate2D) {
        homePositionAdded = true
        self.region = MKCoordinateRegion(center: location,
                                         span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }
    func updateLocation(location: CLLocationCoordinate2D) {
        if !homePositionAdded {
            self.region = MKCoordinateRegion(center: location,
                                             span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40))
        }
        self.mineLocation[0] = Plane(id:UUID().uuidString, coordinate: location, mine: true)
    }
    func cleanDatabase(){
        database.cleanDatabase()
    }
    func searchDevice() {
        peripherals.removeAll()
        bluetoothManager.search()
    }
    func connectTo(_ periperal: CBPeripheral) {
        bluetoothManager.connect(periperal)
        showPeripherals = false
    }
    
    //MARK: Private functions
    private func MSPTelemetry(start: Bool){
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
        
        if start {
            timerRequestMSP = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
                guard let writeChars = bluetoothManager.writeCharacteristic,
                      let peripheral = bluetoothManager.connectedPeripheral else {
                    return
                }
                telemetryManager.requestTelemetry(peripheral: peripheral,
                                                  characteristic: writeChars,
                                                  writeType: bluetoothManager.writeTypeCharacteristic)
            }
        }
    }
}
