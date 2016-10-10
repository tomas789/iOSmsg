//
//  CameraDeviceStatistics.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class CameraDeviceStatistics: StatisticsItem {
    var framesRecorded = 0
    var framesDropped = 0
    var failMessage: String?
    
    func increaseFramesRecorded() {
        framesRecorded += 1
    }
    
    func increaseFramesDropped() {
        framesDropped += 1
    }
    
    func setFailMessage(message: String) {
        failMessage = message
    }
    
    func getLabel() -> String {
        return "Camera statistics"
    }
    
    func getMessage() -> String {
        if let message = failMessage {
            return message
        } else {
            return "Frames dropped: \(framesDropped) recorded: \(framesRecorded)"
        }
    }
}
