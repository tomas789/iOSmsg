//
//  TextStatistics.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class TextStatistics: StatisticsItem {
    var label = "No label"
    var message = "No message"
    
    init(label: String, message: String) {
        self.label = label
        self.message = message
    }
    
    func getLabel() -> String {
        return label
    }
    
    func getMessage() -> String {
        return message
    }
    
    
}
