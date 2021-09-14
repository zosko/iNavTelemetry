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
    @Published var peripheralFound : CBPeripheral!
    @Published var connected : Bool = false
 
    private var centralManager: CBCentralManager?
    private var _connectedPeripheral: CBPeripheral?
    
    var connectedPeripheral: CBPeripheral? { return _connectedPeripheral }
    var writeCharacteristic: CBCharacteristic?
    var writeTypeCharacteristic: CBCharacteristicWriteType = .withoutResponse
    
    override init(){
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    //MARK: Internal functions
    func search() {
        if CBCentralManager.authorization == .denied { return }
        
        if _connectedPeripheral != nil {
            centralManager!.cancelPeripheralConnection(_connectedPeripheral!)
            _connectedPeripheral = nil
        }
        else{
            centralManager!.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.centralManager!.stopScan()
            }
        }
    }
    func connect(_ periperal: CBPeripheral) {
        self.centralManager!.connect(periperal, options: nil)
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
        _connectedPeripheral!.delegate = self
        _connectedPeripheral!.discoverServices(nil)
        
        connected = true
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("FailToConnect" + error!.localizedDescription)
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("FailToDisconnect" + error!.localizedDescription)
            
            var timeoutSeconds = 0;
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                timeoutSeconds += 1
                
                if self._connectedPeripheral!.state == .connected {
                    print("connected....")
                    timer.invalidate();
                }
                else if self._connectedPeripheral!.state == .connecting {
                    print("connecting....")
                }
                else if self._connectedPeripheral!.state == .disconnecting {
                    print("disconnecting....")
                }
                else if self._connectedPeripheral!.state == .disconnected {
                    print("disconnected....")
                    self.centralManager!.connect(self._connectedPeripheral!, options: nil)
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
    }
}
