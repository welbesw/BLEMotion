//
//  Peripheral.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PeripheralDelegate {
    func newMotionPoint(x: Double, y: Double, z: Double)
}

public class Peripheral: NSObject, CBPeripheralDelegate {
    
    let cbPeripheral: CBPeripheral
    var advertisementData: [String : Any]
    var RSSI: Float
    
    var delegate: PeripheralDelegate?
    
    var motionService: CBService?
    var motionCharacteristic: CBCharacteristic?
    
    init(cbPeripheral: CBPeripheral, advertisementData: [String : Any], RSSI: Float) {
        self.cbPeripheral = cbPeripheral
        self.advertisementData = advertisementData
        self.RSSI = RSSI
        
        super.init()
        self.cbPeripheral.delegate = self
    }
    
    var name: String {
        if let peripheralName = cbPeripheral.name {
            return peripheralName
        } else if let adName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            return adName
        } else {
            return "Unknown"
        }
    }
    
    var uuid: String {
        return cbPeripheral.identifier.uuidString
    }
    
    func discoverServices() {
        cbPeripheral.discoverServices([BluetoothPeripheralManager.MotionServiceUUID])
    }
}

extension Peripheral {
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            
            if data.count >= 24 {
                let xData = data.subdata(in: 0..<8)
                let yData = data.subdata(in: 8..<16)
                let zData = data.subdata(in: 16..<24)
                
                guard let x = xData.to(type: Double.self), let y = yData.to(type: Double.self), let z = zData.to(type: Double.self) else {
                    print("Failed to convert data to doubles: \(data.hexEncodedString())")
                    return
                }
                
                print("x: \(x) y: \(y) z:\(z)")
                
                delegate?.newMotionPoint(x: x, y: y, z: z)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        motionService = peripheral.services?.first(where: { $0.uuid == BluetoothPeripheralManager.MotionServiceUUID })
        
        if let motionService = motionService {
            cbPeripheral.discoverCharacteristics([BluetoothPeripheralManager.MotionCharacteristicUUID], for: motionService)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if service == motionService {
            motionCharacteristic = service.characteristics?.first(where: { $0.uuid == BluetoothPeripheralManager.MotionCharacteristicUUID })
            
            if let motionCharacteristic = motionCharacteristic {
                peripheral.setNotifyValue(true, for: motionCharacteristic)
            }
        }
    }
}
