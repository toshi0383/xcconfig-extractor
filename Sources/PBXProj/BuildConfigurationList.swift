//
//  BuildConfigurationList.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public struct BuildConfigurationList: IsaObject {
    public let object: [String: Any]
    public let buildConfigurations: [BuildConfiguration]
    public let defaultConfigurationName: String?
    public let defaultConfigurationIsVisible: String
    public init(_ o: [String: Any], objects: [String: Any]) {
        self.object = o
        self.defaultConfigurationName = o["defaultConfigurationName"] as? String
        let buildConfigurationKeys = o["buildConfigurations"] as! [String]
        self.buildConfigurations = buildConfigurationKeys.map { key in (objects[key] as! [String: Any], objects) }
            .map(BuildConfiguration.init)
        self.defaultConfigurationIsVisible = o["defaultConfigurationIsVisible"] as! String
    }
}

public struct BuildConfiguration: IsaObject {
    public let object: [String: Any]
    public let name: String
    public let baseConfigurationReference: FileReference?
    public let buildSettings: [String: Any]
    public init(_ o: [String: Any], objects: [String: Any]) {
        self.object = o
        self.name = o["name"] as! String
        self.baseConfigurationReference = FileReference(from: o["baseConfigurationReference"], objects: objects)
        self.buildSettings = o["buildSettings"] as! [String: Any]
    }
}
