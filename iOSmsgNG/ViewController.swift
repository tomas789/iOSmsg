//
//  ViewController.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var userDefaults = UserDefaults()
    var statisticsTableViewController: StatisticsTableViewController!
    var connector: RabbitConnector!
    var uiEnabled = true
    var settingsTableViewController: SettingsTableViewController!
    
    // MARK: Outlets
    
    @IBOutlet weak var statisticsTableView: UITableView!
    
    @IBOutlet weak var hostnameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var topStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserDefaults()
        
        connector = RabbitConnector()
        
        statisticsTableViewController = StatisticsTableViewController()
        statisticsTableView.dataSource = statisticsTableViewController
        
        loadStatistics()
        setControlsState(enabled: uiEnabled)
        
        /* This is VERY expansive. Switch to RxSwift */
        Timer.scheduledTimer(timeInterval: 1/25.0, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print(statisticsTableView.bounds)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier ?? "") == "SwitchToSettingsView" {
            let controller: SettingsTableViewController = segue.destination as! SettingsTableViewController
            controller.connector = connector
        }
    }
    
    func loadUserDefaults() {
        let fields = [hostnameField, usernameField, passwordField]
        for field in fields {
            let identifier = getIdentifierForField(field: field!)
            let defaultValue = userDefaults.object(forKey: identifier) as? String
            field!.text = defaultValue
        }
    }
    
    func timerUpdate() {
        statisticsTableView.reloadData()
        if connector.connected == uiEnabled {
            setControlsState(enabled: !uiEnabled)
        }
    }
    
    func setControlsState(enabled: Bool) {
        uiEnabled = enabled
        hostnameField.isEnabled = enabled
        usernameField.isEnabled = enabled
        passwordField.isEnabled = enabled
        if enabled {
            connectButton.setTitle("Connect", for: .normal)
        } else {
            connectButton.setTitle("Disconnect", for: .normal)
            
        }
    }
    
    func loadStatistics() {
        let connStat = connector.connectionStatistic
        statisticsTableViewController.connectionStatistics.append(connStat)
        let allStatistics = connector.getAllModuleStatistics()
        statisticsTableViewController.sensorStatistics.append(contentsOf: allStatistics)
    }
    
    func getIdentifierForField(field: UITextField) -> String {
        return "field-\(field.placeholder!)"
    }
    
    // MARK: Actions
    
    @IBAction func fieldChanged(_ sender: UITextField) {
        let identifier = getIdentifierForField(field: sender)
        userDefaults.set(sender.text, forKey: identifier)
    }
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        if connector.connected {
            connector.disconnect()
        } else {
            let host = hostnameField.text ?? ""
            let port = 5672
            let user = usernameField.text ?? ""
            let passwd = passwordField.text ?? ""
            connector.connect(host: host, port: port, username: user, password: passwd)
        }
    }
}

