//
//  SwitchTableViewCell.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    var model: SwitchSettingItem!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switched(_ sender: UISwitch) {
        model.switchStatus = `switch`.isOn
    }
    
    func setModel(model: SwitchSettingItem) {
        self.model = model
        label.text = model.description
        `switch`.isOn = model.switchStatus
    }
}
