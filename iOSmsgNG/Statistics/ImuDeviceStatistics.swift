//
//  ImuDeviceStatistics.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class ImuDeviceStatistics: StatisticsItem {
    var failCounter = 0
    var successCounter = 0
    var deviceName: String
    
    init(deviceName: String) {
        self.deviceName = deviceName
    }
    
    func increaseSuccessCounter() {
        successCounter += 1
    }
    
    func increaseFailedCounter() {
        failCounter += 1
    }
    
    internal func getMessage() -> String {
        return "Failed: \(failCounter) Success: \(successCounter)"
    }

    internal func getLabel() -> String {
        return "Stats for \(deviceName)"
    }
}
