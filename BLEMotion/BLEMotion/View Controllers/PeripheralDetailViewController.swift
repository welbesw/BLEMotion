//
//  PeripheralDetailViewController.swift
//  BLEMotion
//
//  Created by William Welbes on 4/10/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class PeripheralDetailViewController: UIViewController {

    var peripheral: Peripheral?
    
    @IBOutlet var peripheralNameLabel: UILabel!
    @IBOutlet var xValueLabel: UILabel!
    @IBOutlet var yValueLabel: UILabel!
    @IBOutlet var zValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xValueLabel.text = ""
        yValueLabel.text = ""
        zValueLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let peripheral = peripheral {
            BluetoothManager.sharedInstance.connect(peripheral: peripheral)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMotionPoint(notification:)), name: .newMotionPoint, object: nil)
        
        peripheralNameLabel.text = peripheral?.name ?? "[Unknown]"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let peripheral = peripheral {
            BluetoothManager.sharedInstance.disconnect(peripheral: peripheral)
        }
        
        NotificationCenter.default.removeObserver(self, name: .newMotionPoint, object: nil)
    }
    
    @objc func newMotionPoint(notification: Notification) {
        if let motionPoint = notification.object as? MotionPoint {
            if motionPoint.peripheralUUID == peripheral?.uuid {
                DispatchQueue.main.async {
                    self.xValueLabel.text = String(format: "%0.5f", motionPoint.x)
                    self.yValueLabel.text = String(format: "%0.5f", motionPoint.y)
                    self.zValueLabel.text = String(format: "%0.5f", motionPoint.z)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "VisualizePushSegue" {
            if let visualizeViewController = segue.destination as? VisualizeViewController {
                visualizeViewController.peripheral = peripheral
            }
        }
    }

}
