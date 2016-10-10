//
//  ImuModuleSettings.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class ImuModuleSettings: ModuleSettingProtocol {
    var name: String { get { return moduleName } }
    var items: [SettingItemProtocol] {
        get {
            return [
                sendDataSettingItem,
                exchangeSettingItem,
                updateRateSettingItem
            ]
        }
    }
    
    let moduleName: String
    
    var sendDataSettingItem: SwitchSettingItem
    var exchangeSettingItem: FieldSettingItem
    var updateRateSettingItem: RateSettingItem
    
    init(moduleName: String, defaultExchangeName: String, changeHandler: @escaping (String) -> ()) {
        self.moduleName = moduleName
        
        sendDataSettingItem = SwitchSettingItem(description: "Send data", switchStatus: true) { param in
            changeHandler("sendData")
        }
        
        exchangeSettingItem = FieldSettingItem(description: "Exchange", text: "", placeholder: defaultExchangeName) { param in
            changeHandler("exchange")
        }
        
        updateRateSettingItem = RateSettingItem(description: "Update rate", min: 1, max: 100, defaultValue: 100, unit: "Hz", format: "%.0f %@") { param in
            changeHandler("exchange")
        }
    }
}
