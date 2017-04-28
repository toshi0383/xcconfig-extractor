//
//  Project.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/28.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

struct Project: IsaObject {
    let object: [String: Any]
    let attributes: [String: Any]
    let buildConfigurationList: BuildConfigurationList
    let compatibilityVersion: String
    let developmentRegion: String
    let hasScannedForEncodings: String
    let knownRegions: [String]
    let mainGroup: String // TODO
    let productRefGroup: String // TODO
    let projectDirPath: String
    let projectRoot: String
    let targets: [NativeTarget]
    init(_ o: [String: Any], objects: [String: Any]) {
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
        self.projectRoot = o["projectRoot"] as! String
        self.targets = (o["targets"] as! [String]).map { k in
            let target = objects[k] as! [String: Any]
            return NativeTarget(target: target, objects: objects)
        }
    }
}
