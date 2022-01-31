//
//  BluetoothManager.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/12/21.
//

import Foundation
import CoreBluetooth
import Combine

final class BluetoothManager: ObservableObject {

    @Published private(set) var dataReceived: Data?
    @Published var isScanning: Bool = false
    @Published var connected: Bool = false
    
    private let bluetoothCommunicator: BluetoothProtocol
    
    // MARK: - Initialization
    init(bluetoothCommunicator: BluetoothProtocol = BluetoothCommunicator()){
        self.bluetoothCommunicator = bluetoothCommunicator
        
        setupBinding()
    }
    
    // MARK: - Private methods
    private func setupBinding() {
        bluetoothCommunicator.isScanning
            .assign(to: &$isScanning)
        
        bluetoothCommunicator.dataReceived
            .assign(to: &$dataReceived)
        
        bluetoothCommunicator.connected
            .assign(to: &$connected)
    }
    
    // MARK: - Internal methods
    func search() -> AnyPublisher<[CBPeripheral], Never> {
        bluetoothCommunicator.search()
            .eraseToAnyPublisher()
    }
    func connect(_ peripheral: CBPeripheral) {
        bluetoothCommunicator.connect(peripheral)
    }
    func disconnect(_ peripheral: CBPeripheral) {
        bluetoothCommunicator.disconnect(peripheral)
    }
    func write(_ data: Data){
        bluetoothCommunicator.write(data: data)
    }
}
