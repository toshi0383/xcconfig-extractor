//
//  Pbxproj.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import PathKit

public struct Pbxproj {
    public let archiveVersion: String
    public let classes: [String: Any]?
    public let objectVersion: String
    public let rootObject: Project
    public let objects: [String: Any]
    fileprivate let raw: Any
    public init?(data: Data) {
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
        self.classes = values["classes"] as? [String: Any]
        self.objectVersion = values["objectVersion"] as! String
        guard let rootObjectKey = values["rootObject"] as? String,
            let objects = values["objects"] as? [String: Any]
            else {
            fatalError("rootObject or objects not found!")
        }
        self.objects = objects
        let rootObject = Project(key: rootObjectKey, value: objects[rootObjectKey] as! [String: Any], objects: objects)!
        self.rootObject = rootObject
    }
    func object<T>(for key: String) -> T {
        return objects[key] as! T
    }
}
