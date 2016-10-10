//
//  FieldTableViewCell.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import UIKit

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    var model: FieldSettingItem!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var field: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        field.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func fieldValueEdited(_ sender: UITextField) {
        model.text = field.text ?? ""
    }
    
    
    func setModel(model: FieldSettingItem) {
        self.model = model
        label.text = model.description
        field.text = model.text
        field.placeholder = model.placeholder
    }
    
    // MARK : UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        return true
    }

}
