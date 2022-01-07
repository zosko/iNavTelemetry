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
    @Published private(set) var mineLocation = Plane(id: "", coordinate: .init(), mine: true)
    @Published private(set) var allPlanes = [Plane(id: "", coordinate: .init(), mine: false)]
    @Published private(set) var logsData: [URL] = []
    @Published private(set) var bluetootnConnected = false
    @Published private(set) var homePositionAdded = false
    @Published private(set) var seconds = 0
    @Published private(set) var bluetoothScanning = false
    @Published private(set) var telemetry = TelemetryManager.InstrumentTelemetry(packet: TelemetryManager.Packet(), telemetryType: .unknown)
    @Published var showListLogs = false
    @Published var showPeripherals = false
    
    var region = MKCoordinateRegion()
    var peripherals : [CBPeripheral] = []
    
    @ObservedObject private var bluetoothManager = BluetoothManager()
    @ObservedObject private var socketCommunicator = SocketComunicator()
    
    private var cloudStorage = CloudStorage()
    private var database = Database()
    private var cancellable: [AnyCancellable] = []
    private var telemetryManager = TelemetryManager()
    private var timerFlying: Timer?
    
    override init(){
        super.init()
        self.region.span = MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
        telemetryManager.addBluetoothManager(bluetoothManager: bluetoothManager)
        
        Publishers.CombineLatest(socketCommunicator.$planes, $mineLocation)
            .receive(on: DispatchQueue.main)
            .map{ $0 + [$1] }
            .assign(to: &$allPlanes)
        
        Publishers.CombineLatest(database.$logs,cloudStorage.$logs)
            .receive(on: DispatchQueue.main)
            .map { localLogs, remoteLogs in
                let merged = localLogs + remoteLogs
                let sorted = merged.sorted { first, second in
                    return Int(first.lastPathComponent)! > Int(second.lastPathComponent)!
                }
                var filtered: [URL] = []
                var prevFileName = ""
                sorted.forEach { url in
                    
                    if prevFileName.isEmpty {
                        prevFileName = url.lastPathComponent
                        filtered.append(url)
                    }
                    else {
                        if url.lastPathComponent != prevFileName {
                            filtered.append(url)
                        }
                        prevFileName = url.lastPathComponent
                    }
                }
                return filtered
            }
            .assign(to: &$logsData)
        
        bluetoothManager.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: &$bluetoothScanning)
        
        bluetoothManager.$dataReceived
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                guard self.telemetryManager.parse(incomingData: data) else { return }
                self.telemetry = self.telemetryManager.telemetry
                
                if (self.telemetry.packet.gps_sats > 5 && !self.homePositionAdded) {
                    self.showHomePosition(location: self.telemetry.location)
                }
                
                self.updateLocation(location: self.telemetry.location)
                
                if self.homePositionAdded {
                    let logTelemetry = TelemetryManager.LogTelemetry(lat: self.telemetry.location.latitude,
                                                                     lng: self.telemetry.location.longitude)
                    
                    socketCommunicator.sendPlaneData(location: logTelemetry)
                    database.saveTelemetryData(packet: logTelemetry)
                }
            }.store(in: &cancellable)
        
        bluetoothManager.$peripheralFound
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] peripheral in
                guard let device = peripheral,
                      let name = device.name, !name.isEmpty else { return }
                
                if !self.peripherals.contains(device) {
                    self.peripherals.append(device)
                    self.showPeripherals = self.peripherals.count > 0
                }
            }.store(in: &cancellable)
        
        bluetoothManager.$connected
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] connected in
                self.bluetootnConnected = connected
                
                if connected {
                    _ = self.telemetryManager.parse(incomingData: Data()) // initial start for MSP only
                    
                    self.homePositionAdded = false
                    self.seconds = 0
                    timerFlying?.invalidate()
                    timerFlying = nil
                    database.startLogging()
                    
                    timerFlying = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                        if self.telemetry.engine == .armed {
                            self.seconds += 1
                        } else {
                            self.seconds = 0
                        }
                    }
                }
                else{
                    if self.homePositionAdded {
                        if let url = database.stopLogging() {
                            cloudStorage.saveFileToiCloud(url)
                        }
                    }
                    self.homePositionAdded = false
                    timerFlying?.invalidate()
                    timerFlying = nil
                    self.telemetryManager.stopTelemetry()
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
        self.mineLocation = Plane(id:UUID().uuidString, coordinate: location, mine: true)
    }
    func getFlightLogs() {
        database.getLogs()
        cloudStorage.getLogs()
        showListLogs = true
    }
    func cleanDatabase(){
        database.cleanDatabase()
        cloudStorage.cleanDatabase()
        showListLogs = false
    }
    func searchDevice() {
        peripherals.removeAll()
        bluetoothManager.search()
    }
    func connectTo(_ periperal: CBPeripheral) {
        bluetoothManager.connect(periperal)
        showPeripherals = false
    }
}
