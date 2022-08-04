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

class AppViewModel: ObservableObject {
    @Published private(set) var mineLocation = Plane(id: "", coordinate: .init(), mine: true)
    @Published private(set) var allPlanes = [Plane(id: "", coordinate: .init(), mine: false)]
    @Published private(set) var logsData: [URL] = [] {
        didSet {
            showListLogs = logsData.count > 0
        }
    }
    @Published private(set) var connected = false {
        didSet {
            if connected {
                _ = self.telemetryManager.parse(incomingData: Data()) // initial start for MSP only
                
                self.homePositionAdded = false
                self.seconds = 0
                timerFlying?.invalidate()
                timerFlying = nil
                localStorage.start()
                
                timerFlying = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                    if self.telemetry.engine == .armed {
                        self.seconds += 1
                    } else {
                        self.seconds = 0
                    }
                }
            }
            else{
                if let url = localStorage.stop() {
                    cloudStorage.save(file:url)
                }
                self.homePositionAdded = false
                timerFlying?.invalidate()
                timerFlying = nil
                self.telemetryManager.stopTelemetry()
            }
        }
    }
    @Published private(set) var homePositionAdded = false
    @Published private(set) var seconds = 0
    @Published private(set) var bluetoothScanning = false
    @Published private(set) var telemetry = InstrumentTelemetry(packet: Packet(), telemetryType: .unknown) {
        didSet {
            if (self.telemetry.packet.gps_sats > 5 && !self.homePositionAdded) {
                self.showHomePosition(location: self.telemetry.location)
            }
            
            self.updateLocation(location: self.telemetry.location)
            
            if self.homePositionAdded {
                let logTelemetry = LogTelemetry(lat: self.telemetry.location.latitude,
                                                lng: self.telemetry.location.longitude)
                
                socketCommunicator.sendPlaneData(location: logTelemetry)
                localStorage.save(packet: logTelemetry)
            }
        }
    }
    @Published private(set) var showListLogs = false
    @Published private(set) var showPeripherals = false
    @Published private(set) var peripherals: [CBPeripheral] = [] {
        didSet {
            showPeripherals = peripherals.count > 0
        }
    }
    
    var region = MKCoordinateRegion(center: .init(), span: .init(latitudeDelta: 100, longitudeDelta: 100))
    
    @ObservedObject private var bluetoothManager: BluetoothManager
    @ObservedObject private var socketCommunicator: SocketCommunicator
    
    private let cloudStorage: CloudStorage
    private let localStorage: LocalStorage
    private let telemetryManager: TelemetryManager
    private var cancellable: [AnyCancellable] = []
    private var timerFlying: Timer?
    
    private let compassHeading = CompassHeading()
    
    init(cloudStorage: CloudStorage = CloudStorage(),
         localStorage: LocalStorage = LocalStorage(),
         telemetryManager: TelemetryManager = TelemetryManager(),
         bluetoothManager: BluetoothManager = BluetoothManager(),
         socketCommunicator: SocketCommunicator = SocketCommunicator()) {
        
        self.cloudStorage = cloudStorage
        self.localStorage = localStorage
        self.telemetryManager = telemetryManager
        self.bluetoothManager = bluetoothManager
        self.socketCommunicator = socketCommunicator
        
        telemetryManager.addBluetoothManager(bluetoothManager: bluetoothManager)
        
        setupBindings()
    }
    
    // MARK: - Private methods
    private func setupBindings() {
        Publishers.CombineLatest(socketCommunicator.$planes, $mineLocation)
            .map{ $0 + [$1] }
            .assign(to: &$allPlanes)
        
        bluetoothManager.$isScanning
            .assign(to: &$bluetoothScanning)
        
        bluetoothManager.$connected
            .assign(to: &$connected)
        
        bluetoothManager.$dataReceived
            .compactMap({ $0 })
            .sink { [unowned self] data in
                guard self.telemetryManager.parse(incomingData: data) else { return }
                self.telemetry = self.telemetryManager.telemetry
            }.store(in: &cancellable)
        
        compassHeading
            .objectWillChange
            .sink { [unowned self] _ in
                self.telemetry.updateDirectionToPlane(pilotHeading: compassHeading.degrees, pilotLocation: compassHeading.currentLocation)
            }.store(in: &cancellable)
    }
    
    // MARK: - Internal functions
    func stopDetectingProtocol() {
        bluetoothManager.disconnect()
    }
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
        self.mineLocation = Plane(id:"", coordinate: location, mine: true)
    }
    func getFlightLogs() {
        localStorage.fetch()
            .combineLatest(cloudStorage.fetch())
            .map({ $0 + $1 })
            .map({ $0.uniqued().sortFiles() })
            .assign(to: \.logsData, on: self)
            .store(in: &cancellable)
    }
    func cleanDatabase(){
        localStorage.clear()
        cloudStorage.clear()
    }
    func searchDevice() {
        bluetoothManager.search()
            .removeDuplicatePeripherals()
            .assign(to: \.peripherals, on: self)
            .store(in: &cancellable)
    }
    func connectTo(_ periperal: CBPeripheral) {
        bluetoothManager.connect(periperal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.closeBluetoothScreen()
        }
    }
    func closeBluetoothScreen() {
        peripherals.removeAll()
    }
    func closeLogsDataScreen() {
        logsData.removeAll()
    }
}

extension Publisher where Output == [CBPeripheral] {
    func removeDuplicatePeripherals() -> AnyPublisher<[CBPeripheral], Self.Failure> {
        self.map { peripherals in
            var filtered = Set<CBPeripheral>()
            peripherals.forEach { peripheral in
                filtered.insert(peripheral)
            }
            return Array(filtered)
        }.eraseToAnyPublisher()
    }
}

extension Sequence where Iterator.Element == URL {
    func uniqued() -> [Element] {
        var filtered = Set<Element>()
        
        var prevFileName = ""
        forEach { url in
            if prevFileName.isEmpty {
                prevFileName = url.lastPathComponent
                filtered.insert(url)
            }
            else {
                if url.lastPathComponent != prevFileName {
                    filtered.insert(url)
                }
                prevFileName = url.lastPathComponent
            }
        }
        return Array(filtered)
    }
}
