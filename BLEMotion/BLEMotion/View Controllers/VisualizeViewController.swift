//
//  VisualizeViewController.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit
import SceneKit

class VisualizeViewController: UIViewController {
    
    var peripheral: Peripheral?
    
    @IBOutlet var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var boxNode: SCNNode!
    
    var x = 0
    var y = 0
    var z = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupCamera()
        addShape()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let peripheral = peripheral {
            BluetoothManager.sharedInstance.connect(peripheral: peripheral)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMotionPoint(notification:)), name: .newMotionPoint, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let peripheral = peripheral {
            BluetoothManager.sharedInstance.disconnect(peripheral: peripheral)
        }
        
        NotificationCenter.default.removeObserver(self, name: .newMotionPoint, object: nil)
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        scnView.backgroundColor = .white
        
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func addShape() {
        let geometry = SCNBox(width: 10.0, height: 1.0, length: 20.0, chamferRadius: 0.5)
        geometry.materials.first?.diffuse.contents = UIColor.lightGray
        
        boxNode = SCNNode(geometry: geometry)
        
        scnScene.rootNode.addChildNode(boxNode)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    @objc func newMotionPoint(notification: Notification) {
        if let motionPoint = notification.object as? MotionPoint {
            if motionPoint.peripheralUUID == peripheral?.uuid {
                DispatchQueue.main.async {
                    self.boxNode.eulerAngles = SCNVector3(motionPoint.x, motionPoint.y, -1 * motionPoint.z)
                }
            }
        }
    }
}
