//
//  ResultObject.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import PathKit

class ResultObject: Equatable {
    let path: Path
    var settings: [String]
    let targetName: String?
    let configurationName: String?
    init(path: Path, settings: [String], targetName: String? = nil, configurationName: String? = nil) {
        self.path = path
        self.settings = settings
        self.targetName = targetName
        self.configurationName = configurationName
    }
}
func ==(lhs: ResultObject, rhs: ResultObject) -> Bool {
    guard lhs.path == rhs.path else { return false }
    guard lhs.settings == rhs.settings else { return false }
    guard lhs.targetName == rhs.targetName else { return false }
    guard lhs.configurationName == rhs.configurationName else { return false }
    return true
}
