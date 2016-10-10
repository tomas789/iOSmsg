//
//  NumberStatistics.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class NumberStatistics: StatisticsItem {
    var label = "No label"
    var number: Double = 0
    
    var numberFormat = "%f"
    
    init(label: String, number: Double) {
        self.label = label
        self.number = number
    }
    
    func getLabel() -> String {
        return label
    }
    
    func getMessage() -> String {
        return String(format: numberFormat, number)
    }
    
    
}
