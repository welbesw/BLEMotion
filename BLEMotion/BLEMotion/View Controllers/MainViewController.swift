//
//  ViewController.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var peripheralSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralSwitch.addTarget(self, action: #selector(didTogglePeripheralModeSwitch), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        peripheralSwitch.setOn(BluetoothPeripheralManager.sharedInstance.isAdvertisting, animated: false)
    }
    
    @IBAction func didTogglePeripheralModeSwitch() {
        if peripheralSwitch.isOn {
            BluetoothPeripheralManager.sharedInstance.startAdvertising()
            startMonitoringMotion()
        } else {
            BluetoothPeripheralManager.sharedInstance.stopAdvertising()
            stopMonitoringMotion()
        }
    }
    
    func startMonitoringMotion() {
        MotionManager.sharedInstance.motionDataUpdated = {(x, y, z) in
            print("x: \(x) y: \(y), z: \(z)")
            BluetoothPeripheralManager.sharedInstance.updateMotionValue(x: x, y: y, z: z)
        }
        MotionManager.sharedInstance.startDeviceMotion()
    }
    
    func stopMonitoringMotion() {
        MotionManager.sharedInstance.stopDeviceMotion()
    }


}

