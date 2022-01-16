//
//  BluetoothManager.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/12/21.
//

import Foundation
import CoreBluetooth
import Combine

final class BluetoothManager: NSObject, ObservableObject {
    
    @Published private(set) var dataReceived: Data?
    @Published private(set) var connected : Bool = false
    @Published private(set) var isScanning : Bool = false
    @Published private(set) var listPeripherals: CBPeripheral?
    @Published private(set) var peripheral: CBPeripheral? {
        didSet {
            connected = peripheral?.state == .connected
        }
    }
    private(set) var writeCharacteristic: CBCharacteristic?
    private(set) var writeTypeCharacteristic: CBCharacteristicWriteType = .withoutResponse
    private var centralManager: CBCentralManager?

    // MARK: - Initialization
        override init(){
            super.init()
            
            self.centralManager = CBCentralManager(delegate: self, queue: .main)
        }
    
    // MARK: - Internal functions
    func search() {
        if CBCentralManager.authorization == .denied { return }
        guard let manager = centralManager else { return }
        
        if connected,
           let peripheral = self.peripheral {
            manager.cancelPeripheralConnection(peripheral)
        } else {
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            isScanning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                manager.stopScan()
                self?.isScanning = false
            }
        }
    }
    func connect(_ periperal: CBPeripheral) {
        guard let manager = centralManager else { return }
        manager.connect(periperal, options: nil)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unknown:
            print("Bluetooth Unknown.")
        case .resetting:
            print("The update is being started. Please wait until Bluetooth is ready.")
        case .unsupported:
            print("This device does not support Bluetooth low energy.")
        case .unauthorized:
            print("This app is not authorized to use Bluetooth low energy.")
        case .poweredOff:
            print("You must turn on Bluetooth in Settings in order to use the reader.")
        case .poweredOn:
            print("Bluetooth power on")
        default:
            print("Bluetooth default state")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        listPeripherals = peripheral
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([
            CBUUID(string: BluetoothType.frskyBuildIn.uuidService),
            CBUUID(string: BluetoothType.hm10.uuidService),
            CBUUID(string: BluetoothType.tbsCrossfire.uuidService)
        ])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard let error = error else {
            self.peripheral = peripheral
            return
        }
        print("FailToConnect" + error.localizedDescription)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let error = error else {
            self.peripheral = peripheral
            return
        }
        print("FailToDisconnect" + error.localizedDescription)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            print("Error receiving data \(characteristic)")
            return
        }
        dataReceived = data
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("peripheral with no services")
            return
        }
        services.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            print("peripheral with no characteristic")
            return
        }
        let validChars = characteristics
            .filter {
                $0.uuid == CBUUID(string: BluetoothType.frskyBuildIn.uuidChar) ||
                $0.uuid == CBUUID(string: BluetoothType.hm10.uuidChar) ||
                $0.uuid == CBUUID(string: BluetoothType.tbsCrossfire.uuidChar)
            }
        
        validChars.forEach { characteristic in
            peripheral.setNotifyValue(true, for: characteristic)
            self.writeCharacteristic = characteristic
            self.writeTypeCharacteristic = characteristic.properties == .write ? .withResponse : .withoutResponse
            print("UUID: [\(characteristic.uuid.uuidString)]")
        }
    }
}
