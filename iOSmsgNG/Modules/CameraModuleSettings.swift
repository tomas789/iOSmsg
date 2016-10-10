//
//  CameraModuleSettings.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class CameraModuleSettings: ModuleSettingProtocol {
    var name: String { get { return "Camera" } }
    var items: [SettingItemProtocol] {
        get {
            return [
                sendDataSettingItem,
                exchangeSettingItem,
                refreshRateSettingItem,
                adjustDeviceOrientationSettingItem,
                jpegCompressionSettingItem
            ]
        }
    }
        
    var sendDataSettingItem: SwitchSettingItem
    var exchangeSettingItem: FieldSettingItem
    var refreshRateSettingItem: RateSettingItem
    var adjustDeviceOrientationSettingItem: SwitchSettingItem
    var jpegCompressionSettingItem: RateSettingItem
    
    init(defaultExchangeName: String, changeHandler: @escaping (String) -> ()) {
        sendDataSettingItem = SwitchSettingItem(description: "Send data", switchStatus: true) {
            changeHandler("sendData")
        }
        exchangeSettingItem = FieldSettingItem(description: "Exchange", text: "", placeholder: defaultExchangeName) {
            changeHandler("exchange")
        }
        refreshRateSettingItem = RateSettingItem(description: "Refresh rate", min: 2, max: 30, defaultValue: 30, unit: "Hz", format: "%.0f %@") {
            changeHandler("refreshRate")
        }
        adjustDeviceOrientationSettingItem = SwitchSettingItem(description: "Adjust video to device orientation", switchStatus: true) {
            changeHandler("adjustDeviceOrientation")
        }
        jpegCompressionSettingItem = RateSettingItem(description: "JPEG compression", min: 0, max: 1, defaultValue: 0.3, unit: "", format: "%.2f %@") {
            changeHandler("jpegCompression")
        }
    }
}
