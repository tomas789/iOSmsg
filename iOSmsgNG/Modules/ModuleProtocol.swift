//
//  ModuleProtocol.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

protocol ModuleProtocol {
    var statistics: [StatisticsItem] { get }
    var settings: [ModuleSettingProtocol] { get }
    
    func start();
    func stop();
}
