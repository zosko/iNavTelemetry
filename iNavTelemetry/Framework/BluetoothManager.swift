//
//  BluetoothManager.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/12/21.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    
    @Published var dataReceived: Data = Data()
    @Published var peripheralFound : CBPeripheral? = nil
    @Published var connected : Bool = false
    @Published var isScanning : Bool = false
    
    var connectedPeripheral: CBPeripheral? { return _connectedPeripheral }
    var writeCharacteristic: CBCharacteristic?
    var writeTypeCharacteristic: CBCharacteristicWriteType = .withoutResponse
    
    @Published private var centralManager: CBCentralManager?
    private var _connectedPeripheral: CBPeripheral? = nil
    private var timerReconnect: Timer?
    
    //MARK: Init
    override init(){
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    //MARK: Internal functions
    func search() {
        if CBCentralManager.authorization == .denied { return }
        
        guard let connectedPeriperal = _connectedPeripheral, let manager = centralManager else {
            guard let manager = centralManager else { return }
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            isScanning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                manager.stopScan()
                self.isScanning = false
            }
            return
        }
        manager.cancelPeripheralConnection(connectedPeriperal)
        _connectedPeripheral = nil
        timerReconnect?.invalidate()
        timerReconnect = nil
    }
    func connect(_ periperal: CBPeripheral) {
        guard let manager = centralManager else { return }
        manager.connect(periperal, options: nil)
        timerReconnect?.invalidate()
        timerReconnect = nil
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
        peripheralFound = peripheral
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        _connectedPeripheral = peripheral
        guard let connectedPeripheral = _connectedPeripheral else { return }
        connectedPeripheral.delegate = self
        connectedPeripheral.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("FailToConnect" + error!.localizedDescription)
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("FailToDisconnect" + error!.localizedDescription)
            
            guard let connectedPeripheral = _connectedPeripheral, let manager = centralManager else { return }
            
            var timeoutSeconds = 0;
            timerReconnect = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                timeoutSeconds += 1
                
                if connectedPeripheral.state == .connected {
                    print("connected....")
                    timer.invalidate();
                }
                else if connectedPeripheral.state == .connecting {
                    print("connecting....")
                }
                else if connectedPeripheral.state == .disconnecting {
                    print("disconnecting....")
                }
                else if connectedPeripheral.state == .disconnected {
                    print("disconnected....")
                    manager.connect(connectedPeripheral, options: nil)
                }
                
                if timeoutSeconds > 100 {
                    print("timeout")
                    self._connectedPeripheral = nil
                    self.connected = false
                    timer.invalidate()
                }
                
            })
        }
        else {
            self._connectedPeripheral = nil
            self.connected = false
            timerReconnect?.invalidate()
            timerReconnect = nil
        }
    }
    
    //MARK: PeripheralDelegates
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving notification for characteristic \(characteristic) : " + error!.localizedDescription)
            return
        }
        guard let data = characteristic.value else {
            return
        }
        dataReceived = data
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            peripheral.setNotifyValue(true, for: characteristic)
            
            if characteristic.uuid == CBUUID(string: TelemetryManager.BluetoothUUID.frskyChar.rawValue){
                self.writeCharacteristic = characteristic
                self.writeTypeCharacteristic = characteristic.properties == .write ? .withResponse : .withoutResponse
            }
            
            if characteristic.uuid == CBUUID(string: TelemetryManager.BluetoothUUID.hm10Char.rawValue){
                self.writeCharacteristic = characteristic
                self.writeTypeCharacteristic = characteristic.properties == .write ? .withResponse : .withoutResponse
            }

        }
        self.connected = true
    }
}
