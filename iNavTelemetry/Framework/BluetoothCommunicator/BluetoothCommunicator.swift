//
//  BluetoothCommunicator.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 30.1.22.
//

import Foundation
import Combine
import CoreBluetooth

protocol BluetoothProtocol {
    var dataReceived: Published<Data?>.Publisher { get }
    var isScanning: Published<Bool>.Publisher { get }
    var connected: Published<Bool>.Publisher { get }
    
    func search() -> AnyPublisher<[CBPeripheral], Never>
    func connect(_ periperal: CBPeripheral)
    func disconnect()
    func write(data: Data)
}

final class BluetoothCommunicator: NSObject, BluetoothProtocol {
    var isScanning: Published<Bool>.Publisher { $_isScanning }
    var dataReceived: Published<Data?>.Publisher { $_dataReceived }
    var connected: Published<Bool>.Publisher { $_connected }
    
    @Published private var _connected: Bool = false
    @Published private var _dataReceived: Data?
    @Published private var _isScanning: Bool = false
    
    private var peripheral: CBPeripheral? {
        didSet {
            _connected = peripheral?.state == .connected
        }
    }
    private var listPeripherals: [CBPeripheral] = []
    private var writeCharacteristic: CBCharacteristic?
    private var writeTypeCharacteristic: CBCharacteristicWriteType = .withoutResponse
    private var centralManager: CBCentralManager?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
    
    func search() -> AnyPublisher<[CBPeripheral], Never> {
        Future { [weak self] promise in
            guard CBCentralManager.authorization == .allowedAlways else {
                promise(.success([]))
                return
            }
            
            self?.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            self?._isScanning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.centralManager?.stopScan()
                self?._isScanning = false
                guard let listDevices = self?.listPeripherals else {
                    promise(.success([]))
                    return
                }
                promise(.success(listDevices))
                self?.listPeripherals.removeAll()
            }
            
        }
        .eraseToAnyPublisher()
    }
    func connect(_ peripheral: CBPeripheral) {
        self.centralManager?.connect(peripheral, options: nil)
    }
    func disconnect() {
        guard let peripheral = peripheral else { return }
        self.centralManager?.cancelPeripheralConnection(peripheral)
    }
    func write(data: Data) {
        guard let peripheral = peripheral, let write = writeCharacteristic else { return }
        peripheral.writeValue(data, for: write, type: writeTypeCharacteristic)
    }
}

extension BluetoothCommunicator: CBCentralManagerDelegate {
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
        listPeripherals.append(peripheral)
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

extension BluetoothCommunicator: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        _dataReceived = characteristic.value
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
            writeCharacteristic = characteristic
            writeTypeCharacteristic = characteristic.properties == .write ? .withResponse : .withoutResponse
            print("UUID: [\(characteristic.uuid.uuidString)]")
        }
    }
}
