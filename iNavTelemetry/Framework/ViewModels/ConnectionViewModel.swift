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

class ConnectionViewModel: NSObject, ObservableObject {
    
    @Published var selectedProtocol = TelemetryManager.TelemetryType.smartPort
    @Published var showingActionSheetLogs = false
    @Published var showingActionSheetPeripherals = false
    @Published var telemetry = TelemetryManager.InstrumentTelemetry(packet: TelemetryManager.Packet(),
                                                                    telemetryType: .smartPort,
                                                                    flyTime: 0)
    @Published var peripherals : [CBPeripheral] = []
    
    @ObservedObject private var bluetoothManager = BluetoothManager()
    
    var savedLogs = Database.getLogs()
    
    private var cancellable: [AnyCancellable] = []
    private var telemetryManager = TelemetryManager()
    private var timerRequestMSP: Timer?
    
    override init(){
        super.init()
        
        $selectedProtocol.sink {
            print($0)
            self.telemetryManager.chooseTelemetry(type: $0)
        }.store(in: &cancellable)

        bluetoothManager.$dataReceived.sink { [unowned self] data in
            guard self.telemetryManager.parse(incomingData: data) else {
                return
            }
            self.telemetry = self.telemetryManager.telemetry
        }.store(in: &cancellable)
        
        bluetoothManager.$peripheralFound.sink { [unowned self] peripheral in
            guard let device = peripheral, let _ = device.name else { return }
            
            if !self.peripherals.contains(device) {
                self.peripherals.append(device)
                self.showingActionSheetPeripherals = self.peripherals.count > 0
            }
        }.store(in: &cancellable)
        
        bluetoothManager.$connected.sink { [unowned self]  connected in
            if self.telemetryManager.telemetryType == .msp {
                self.MSPTelemetry(start: connected)
            }
        }.store(in: &cancellable)
    }
    
    //MARK: Internal functions
    func searchDevice() {
        peripherals.removeAll()
        bluetoothManager.search()
    }
    func connectTo(_ periperal: CBPeripheral) {
        bluetoothManager.connect(periperal)
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
