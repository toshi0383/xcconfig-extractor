//
//  BuildConfigurationList.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

struct BuildConfigurationList: IsaObject {
    let object: [String: Any]
    let buildConfigurations: [BuildConfiguration]
    let defaultConfigurationName: String?
    let defaultConfigurationIsVisible: String
    init(_ o: [String: Any], objects: [String: Any]) {
        self.object = o
        self.defaultConfigurationName = o["defaultConfigurationName"] as? String
        let buildConfigurationKeys = o["buildConfigurations"] as! [String]
        self.buildConfigurations = buildConfigurationKeys.map { key in objects[key] as! [String: Any] }
            .map(BuildConfiguration.init)
        self.defaultConfigurationIsVisible = o["defaultConfigurationIsVisible"] as! String
    }
}

struct BuildConfiguration: IsaObject {
    let object: [String: Any]
    let name: String
    let baseConfigurationReference: String?
    let buildSettings: [String: Any]
    init(object o: [String: Any]) {
        self.object = o
        self.name = o["name"] as! String
        self.baseConfigurationReference = o["baseConfigurationReference"] as? String
        self.buildSettings = o["buildSettings"] as! [String: Any]
    }
}
