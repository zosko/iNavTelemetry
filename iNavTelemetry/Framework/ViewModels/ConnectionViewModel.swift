//
//  ConnectionViewModel.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/7/21.
//

import Foundation
import Combine
import CoreBluetooth

class ConnectionViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var selectedProtocol = Telemetry.TelemetryType.SMARTPORT
    @Published var showingActionSheetLogs = false
    @Published var showingActionSheetPeripherals = false
    @Published var telemetry = Telemetry()
    
    var peripherals : [CBPeripheral] = []
    var savedLogs = ["1","2","3","4"]
    
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var writeTypeCharacteristic: CBCharacteristicWriteType = .withoutResponse
    private var connectedUUID: CBUUID?
    private var timerRequestMSP: Timer?
    
    override init(){
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    //MARK: Internal functions
    func searchDevice() {
        guard isBluetoothAuthorized() else { return }
        
        if connectedPeripheral != nil {
            centralManager!.cancelPeripheralConnection(connectedPeripheral!)
            connectedPeripheral = nil
            peripherals.removeAll()
        }
        else{
            peripherals.removeAll()
            centralManager!.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.centralManager!.stopScan()
                self.showingActionSheetPeripherals = self.peripherals.count > 0
            }
        }
    }
    func connectTo(_ periperal: CBPeripheral) {
        self.centralManager!.connect(periperal, options: nil)
    }
    
    //MARK: Private functions
    private func isBluetoothAuthorized() -> Bool {
        return CBCentralManager.authorization == .denied
    }
    private func MSPTelemetry(start: Bool){
        timerRequestMSP?.invalidate()
        timerRequestMSP = nil
        
        if start {
            timerRequestMSP = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
                guard let writeChars = writeCharacteristic,
                      let peripheral = connectedPeripheral else {
                    return
                }
                telemetry.requestTelemetry(peripheral: peripheral, characteristic: writeChars, writeType: writeTypeCharacteristic)
            }
        }
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
        connectedPeripheral!.delegate = self
        connectedPeripheral!.discoverServices(nil)
        
        if telemetry.getTelemetryType() == .MSP {
            MSPTelemetry(start: true)
        }
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
                
                if self.connectedPeripheral!.state == .connected {
                    print("connected....")
                    timer.invalidate();
                }
                else if self.connectedPeripheral!.state == .connecting {
                    print("connecting....")
                }
                else if self.connectedPeripheral!.state == .disconnecting {
                    print("disconnecting....")
                }
                else if self.connectedPeripheral!.state == .disconnected {
                    print("disconnected....")
                    self.centralManager!.connect(self.connectedPeripheral!, options: nil)
                }
                
                if timeoutSeconds > 100 {
                    print("timeout")
                    self.peripherals.removeAll()
                    self.connectedPeripheral = nil
                    if self.telemetry.getTelemetryType() == .MSP {
                        self.MSPTelemetry(start: false)
                    }
                    timer.invalidate();
                }
                
            })
        }
        else {
            self.peripherals.removeAll()
            self.connectedPeripheral = nil
            if self.telemetry.getTelemetryType() == .MSP {
                self.MSPTelemetry(start: false)
            }
        }
    }
    
    //MARK: PeripheralDelegates
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving didWriteValueFor \(characteristic) : " + error!.localizedDescription)
            return
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Error receiving notification for characteristic \(characteristic) : " + error!.localizedDescription)
            return
        }
        if telemetry.parse(incomingData: characteristic.value!) {
            // refreshTelemetry(packet: telemetry.getTelemetry())
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: service)
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
            peripheral.setNotifyValue(true, for: characteristic)
            
            if characteristic.uuid == CBUUID(string: Telemetry.BluetoothUUID.FRSKY_CHAR.rawValue){
                print("FRSKY CONNECTED")
                self.connectedUUID = characteristic.uuid
                self.writeCharacteristic = characteristic
                self.writeTypeCharacteristic = characteristic.properties == .write ? .withResponse : .withoutResponse
            }
            
            if characteristic.uuid == CBUUID(string: Telemetry.BluetoothUUID.HM10_CHAR.rawValue){
                print("HM10 CONNECTED")
                self.connectedUUID = characteristic.uuid
                self.writeCharacteristic = characteristic
                self.writeTypeCharacteristic = characteristic.properties == .write ? .withResponse : .withoutResponse
            }

        }
    }
}
