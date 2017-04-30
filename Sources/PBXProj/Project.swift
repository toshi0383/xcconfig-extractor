//
//  Project.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/28.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public struct Project: IsaObject {
    public let object: [String: Any]
    public let attributes: [String: Any]
    public let buildConfigurationList: BuildConfigurationList
    public let compatibilityVersion: String
    public let developmentRegion: String
    public let hasScannedForEncodings: String
    public let knownRegions: [String]
    public let mainGroup: String // TODO
    public let productRefGroup: String // TODO
    public let projectDirPath: String
    public let projectRoot: String?
    public let targets: [NativeTarget]
    public init(_ o: [String: Any], objects: [String: Any]) {
        self.object = o
        self.attributes = o["attributes"] as! [String: Any]
        let buildConfigurationListKey = o["buildConfigurationList"] as! String
        self.buildConfigurationList = BuildConfigurationList(objects[buildConfigurationListKey] as! [String: Any], objects: objects)
        self.compatibilityVersion = o["compatibilityVersion"] as! String
        self.developmentRegion = o["developmentRegion"] as! String
        self.hasScannedForEncodings = o["hasScannedForEncodings"] as! String
        self.knownRegions = o["knownRegions"] as! [String]
        self.mainGroup = o["mainGroup"] as! String
        self.productRefGroup = o["productRefGroup"] as! String
        self.projectDirPath = o["projectDirPath"] as! String
        self.projectRoot = o["projectRoot"] as? String
        self.targets = (o["targets"] as! [String]).map { k in
            let target = objects[k] as! [String: Any]
            return NativeTarget(target, objects: objects)
        }
    }
}
