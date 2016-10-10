//
//  ModuleSettingProtocol.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

protocol ModuleSettingProtocol {
    var name: String { get }
    var items: [SettingItemProtocol] { get }
}
