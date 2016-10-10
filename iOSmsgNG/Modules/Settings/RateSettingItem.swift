//
//  RateSettingItem.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class RateSettingItem: SettingItemProtocol {
    var prototypeIdentifier: String { get { return "RateCell" } }
    var cellHeight: Int { get { return 97 } }
    
    public private(set) var description: String
    public private(set) var min: Double
    public private(set) var max: Double
    var value: Double { didSet { changeHandler() } }
    public private(set) var unit: String
    public private(set) var format: String
    var changeHandler: () -> ()
    
    init(description: String, min: Double, max: Double, defaultValue: Double, unit: String, format: String, changeHandler: @escaping () -> ()) {
        self.description = description
        self.min = min
        self.max = max
        self.value = defaultValue
        self.unit = unit
        self.format = format
        self.changeHandler = changeHandler
    }
    
    func getValueWithUnit() -> String {
        return String(format: self.format, value, unit)
    }
}
