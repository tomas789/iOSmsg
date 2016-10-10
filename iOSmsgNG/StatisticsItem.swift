//
//  StatisticsItem.swift
//  iOSmsgNG
//
//  Created by Tomas Krejci on 10/9/16.
//  Copyright © 2016 Tomas Krejci. All rights reserved.
//

import Foundation

protocol StatisticsItem {
    func getLabel() -> String;
    func getMessage() -> String;
}
