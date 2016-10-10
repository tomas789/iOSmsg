//
//  FieldSettingItem.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/10/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

class FieldSettingItem: SettingItemProtocol {
    var prototypeIdentifier: String { get { return "FieldCell" } }
    var cellHeight: Int { get { return 83 } }
    
    public private(set) var description: String
    var text: String { didSet { changeHandler() } }
    public private(set) var placeholder: String
    public private(set) var changeHandler: () -> ()
    
    init(description: String, text: String, placeholder: String, changeHandler: @escaping () -> Void) {
        self.description = description
        self.text = text
        self.placeholder = placeholder
        self.changeHandler = changeHandler
    }
    
    func getValueOrPlaceholder() -> String {
        return text.isEmpty ? placeholder : text
    }
}
