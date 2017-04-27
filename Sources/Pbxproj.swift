//
//  Pbxproj.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import PathKit

struct Pbxproj {
    let archiveVersion: String
    let classes: [String: Any]
    let objectVersion: String
    let rootObject: String
    let objects: [String: Any]
    let targets: [NativeTarget]
    fileprivate let raw: Any
    init?(data: Data) {
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let raw = try? PropertyListSerialization.propertyList(from: data, format: &format) else {
            return nil
        }
        self.init(raw: raw)
    }
    fileprivate init(raw: Any) {
        self.raw = raw

        let values = raw as! [String: Any]

        self.archiveVersion = values["archiveVersion"] as! String
        self.classes = values["classes"] as! [String: Any]
        self.objectVersion = values["objectVersion"] as! String
        guard let rootObjectKey = values["rootObject"] as? String,
            let objects = values["objects"] as? [String: Any]
            else {
            fatalError("rootObject or objects not found!")
        }
        self.rootObject = rootObjectKey
        self.objects = objects
        let rootObject = objects[rootObjectKey] as! [String: Any]
        let targetKeys = rootObject["targets"] as! [String]
        self.targets = targetKeys.map { key in
            let target = objects[key] as! [String: Any]
            return (target, objects)
        }.map(NativeTarget.init)
    }
    func object<T>(for key: String) -> T {
        return objects[key] as! T
    }
}
