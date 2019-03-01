//
//  BluetoothPeripheralManager.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    static let MotionServiceUUID = CBUUID(string: "041C7724-DC10-4268-8FA1-864198CA1EAC")
    static let MotionCharacteristicUUID = CBUUID(string: "3B3C6A33-456F-42C0-9EEF-C04CBEF65D03")
    
    let bluetoothPeripheralQueue = DispatchQueue(label: "com.williamwelbes.bluetoothperipheral")
    
    public static let sharedInstance = BluetoothPeripheralManager()
    
    var manager: CBPeripheralManager!
    var motionService: CBMutableService!
    var motionCharacteristic: CBMutableCharacteristic!
    
    var isAdvertisting: Bool = false
    
    override init() {
        super.init()
        
        manager = CBPeripheralManager(delegate: self, queue: bluetoothPeripheralQueue)
    }
    
    public func startAdvertising() {
        if manager.state == .poweredOn && !isAdvertisting {
            isAdvertisting = true
            let advertisementData = ""
            manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[BluetoothPeripheralManager.MotionServiceUUID],
                                         CBAdvertisementDataLocalNameKey: advertisementData])
            addMotionService()
        }
    }
    
    public func stopAdvertising() {
        manager.stopAdvertising()
        isAdvertisting = false
    }
    
    public func addMotionService() {
        motionService = CBMutableService(type: BluetoothPeripheralManager.MotionServiceUUID, primary: true)
        motionCharacteristic = CBMutableCharacteristic(type: BluetoothPeripheralManager.MotionCharacteristicUUID, properties: [.read, .notify], value: nil, permissions: .readable)
        motionService.characteristics = [motionCharacteristic]
        manager.add(motionService)
    }
    
    public func updateMotionValue(x: Double, y: Double, z: Double) {
        
        var payloadData = Data(from: x)
        payloadData.append(Data(from: y))
        payloadData.append(Data(from: z))
        
        manager.updateValue(payloadData, for: motionCharacteristic, onSubscribedCentrals: nil)
    }
}

extension BluetoothPeripheralManager {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral manager state changed: \(peripheral.state.rawValue)")
        
        /*
        if peripheral.state == .poweredOn {
            startAdvertising()
        }
        */
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        if characteristic.uuid == BluetoothPeripheralManager.MotionCharacteristicUUID {
            peripheral.updateValue(Data([UInt8(0x00)]), for: motionCharacteristic, onSubscribedCentrals: nil)
        }
    }
}
