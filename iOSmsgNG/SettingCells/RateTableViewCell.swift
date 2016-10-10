//
//  RateTableViewCell.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import UIKit

class RateTableViewCell: UITableViewCell {
    var model: RateSettingItem!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        print("Slider value changed")
        model.value = Double(slider.value)
        valueLabel.text = model.getValueWithUnit()
    }
  

    func setModel(model: RateSettingItem) {
        self.model = model
        descriptionLabel.text = model.description
        valueLabel.text = model.getValueWithUnit()
        slider.minimumValue = Float(model.min)
        slider.maximumValue = Float(model.max)
        slider.value = Float(model.value)
            /*
        self.model = model
        descriptionLabel.text = model.description
        valueLabel.text = model.getValueWithUnit()
        slider.minimumValue = Float(model.min)
        slider.maximumValue = Float(model.max)
        slider.value = Float(model.value)
 */
    }
}
