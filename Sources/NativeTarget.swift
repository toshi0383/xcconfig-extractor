//
//  NativeTarget.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

struct NativeTarget: IsaObject {
    let object: [String: Any]
    let defaultConfigurationName: String
    let buildConfigurations: [BuildConfiguration]
    init(buildConfigurationList o: [String: Any], objects: [String: Any]) {
        self.object = o
        self.defaultConfigurationName = o["defaultConfigurationName"] as! String
        let buildConfigurationKeys = o["buildConfigurations"] as! [String]
        self.buildConfigurations = buildConfigurationKeys.map { key in objects[key] as! [String: Any] }
            .map(BuildConfiguration.init)
    }
}
