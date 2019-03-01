//
//  MotionManager.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation
import CoreMotion

class MotionManager {
    
    static let sharedInstance = MotionManager()
    
    let motion = CMMotionManager()
    var timer: Timer?
    
    var motionDataUpdated: ((Double, Double, Double) -> (Void))?
    
    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            let updateIntervalSeconds = 1.0 / 30.0
            self.motion.deviceMotionUpdateInterval = updateIntervalSeconds
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the motion data.
            self.timer = Timer(fire: Date(), interval: (updateIntervalSeconds), repeats: true,
                               block: { (timer) in
                                if let data = self.motion.deviceMotion {
                                    // Get the attitude relative to the magnetic north reference frame.
                                    let x = data.attitude.pitch
                                    let y = data.attitude.yaw
                                    let z = data.attitude.roll
                                    
                                    // Use the motion data in your app.
                                    self.motionDataUpdated?(x, y, z)
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }
    
    func stopDeviceMotion() {
        self.motion.stopDeviceMotionUpdates()
        self.timer?.invalidate()
        self.timer = nil
    }
}

