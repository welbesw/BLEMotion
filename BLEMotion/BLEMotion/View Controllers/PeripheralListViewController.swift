//
//  PeripheralListViewController.swift
//  BLEMotion
//
//  Created by William Welbes on 2/28/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class PeripheralListViewController: UITableViewController {

    var selectedPeripheral: Peripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(peripheralAdded(notification:)), name: .peripheralAdded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BluetoothManager.sharedInstance.resetPeripheralList()
        
        BluetoothManager.sharedInstance.startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BluetoothManager.sharedInstance.stopScan()
    }
    
    @objc func peripheralAdded(notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return BluetoothManager.sharedInstance.peripheralsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)

        // Configure the cell...
        let peripheral = BluetoothManager.sharedInstance.peripheralsList[indexPath.row]
        
        cell.textLabel?.text = peripheral.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedPeripheral = BluetoothManager.sharedInstance.peripheralsList[indexPath.row]
        
        performSegue(withIdentifier: "PushPeripheralDetailsSegue", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PushPeripheralDetailsSegue" {
            if let visualizeViewController = segue.destination as? PeripheralDetailViewController, let peripheral = selectedPeripheral {
                visualizeViewController.peripheral = peripheral
                selectedPeripheral = nil
            }
        }
    }
}
