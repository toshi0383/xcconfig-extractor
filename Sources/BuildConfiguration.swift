//
//  BuildConfiguration.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

struct BuildConfiguration: IsaObject {
    let object: [String: Any]
    let name: String
    let baseConfigurationReference: String
    let buildSettings: [String: Any]
    init(object o: [String: Any]) {
        self.object = o
        self.name = o["name"] as! String
        self.baseConfigurationReference = o["baseConfigurationReference"] as! String
        self.buildSettings = o["buildSettings"] as! [String: Any]
    }
}
