//
//  VisualizeViewController.swift
//  BLEMotion
//
//  Created by William Welbes on 2/27/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit
import SceneKit

class VisualizeViewController: UIViewController, PeripheralDelegate {
    
    var peripheral: Peripheral? {
        didSet {
            peripheral?.delegate = self
        }
    }
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let peripheral = peripheral {
            BluetoothManager.sharedInstance.disconnect(peripheral: peripheral)
        }
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
}

extension VisualizeViewController {
    func newMotionPoint(x: Double, y: Double, z: Double) {
        DispatchQueue.main.async {
            self.boxNode.eulerAngles = SCNVector3(x, y, -1 * z)
        }
    }
}
