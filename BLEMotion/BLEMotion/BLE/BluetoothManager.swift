//
//  BluetoothManager.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
    
    public static let sharedInstance = BluetoothManager()
    
    var manager: CBCentralManager!
    let bluetoothQueue = DispatchQueue(label: "com.williamwelbes.bluetooth")
    
    public var peripherals: SynchronizedDictionary<String, Peripheral> = SynchronizedDictionary(queueName: "com.williamwelbes.BLEMotion.peripherals")
    
    public var peripheralsList: [Peripheral] {
        return peripherals.dictionary().values.map { $0 }.sorted { return $0.name < $1.name }
    }
    
    public override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: bluetoothQueue)
    }
    
    public func startScan() {
        if manager.state == .poweredOn {
            manager.scanForPeripherals(withServices: [BluetoothPeripheralManager.MotionServiceUUID], options: nil)
        } else {
            print("startScan manager state: \(manager.state.rawValue)")
        }
    }
    
    public func stopScan() {
        manager.stopScan()
    }
    
    public func connect(peripheral: Peripheral) {
        manager.connect(peripheral.cbPeripheral, options: nil)
    }
    
    public func disconnect(peripheral: Peripheral) {
        manager.cancelPeripheralConnection(peripheral.cbPeripheral)
    }
    
    public func resetPeripheralList() {
        peripherals.setDictionary([:])
    }
}

extension BluetoothManager {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centaral manager state changed: \(central.state.rawValue)")
        if manager.state == .poweredOn {
            startScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let rssiFloat = RSSI.floatValue
        let blePeripheral = Peripheral(cbPeripheral: peripheral, advertisementData: advertisementData, RSSI: rssiFloat)
        if let existingPeripheral = peripherals[blePeripheral.uuid] {
            existingPeripheral.advertisementData = advertisementData
            existingPeripheral.RSSI = rssiFloat
            NotificationCenter.default.post(name: .peripheralUpdated, object: existingPeripheral)
        } else {
            peripherals[blePeripheral.uuid] = blePeripheral
            print("added \(blePeripheral.name)")
            NotificationCenter.default.post(name: .peripheralAdded, object: blePeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect: \(peripheral.name ?? "Unknown")")
        if let existingPeripheral = peripherals[peripheral.identifier.uuidString] {
            existingPeripheral.discoverServices()
        }
    }
}
