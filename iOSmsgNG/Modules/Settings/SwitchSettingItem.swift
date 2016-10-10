//
//  SwitchSettingItem.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class SwitchSettingItem: SettingItemProtocol {
    var prototypeIdentifier: String { get { return "SwitchCell" } }
    var cellHeight: Int { get { return 44 } }
    
    public private(set) var description: String
    public var switchStatus: Bool { didSet { changeHandler() } }
    public private(set) var changeHandler: () -> Void
    
    init(description: String, switchStatus: Bool, changeHandler: @escaping () -> Void) {
        self.description = description
        self.switchStatus = switchStatus
        self.changeHandler = changeHandler
    }
}
