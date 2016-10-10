//
//  SettingsTableViewController.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var connector: RabbitConnector!
    var settings = [ModuleSettingProtocol]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings.append(contentsOf: connector.getAllModuleSettings())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings[section].name
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = settings[indexPath.section].items[indexPath.row]
        return CGFloat(Double(item.cellHeight))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settings[indexPath.section].items[indexPath.row]
        let identifier = item.prototypeIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch item.prototypeIdentifier {
        case "SwitchCell":
            print("Managing switch cell")
            let cellTyped = cell as! SwitchTableViewCell
            cellTyped.setModel(model: item as! SwitchSettingItem)
        case "FieldCell":
            print("Managing field cell")
            let cellTyped = cell as! FieldTableViewCell
            cellTyped.setModel(model: item as! FieldSettingItem)
        case "RateCell":
            print("Managing rate cell")
            let cellTyped = cell as! RateTableViewCell
            cellTyped.setModel(model: item as! RateSettingItem)
        default:
            print("Unknown cell type")
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
