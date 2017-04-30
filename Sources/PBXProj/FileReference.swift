//
//  FileReference.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public enum FileType: String {
    case xcconfig = "text.xcconfig"
}

public struct FileReference: IsaObject {
    public let object: [String : Any]
    public let lastKnownFileType: FileType
    public let path: String
    public let sourceTree: String
    public init(_ o: [String : Any], objects: [String : Any]) {
        self.object = o
        self.lastKnownFileType = FileType(rawValue: o["lastKnownFileType"] as! String)!
        self.path = o["path"] as! String
        self.sourceTree = o["sourceTree"] as! String
    }
    public init?(from id: Any?, objects: [String: Any]) {
        guard let key = id as? String else {
            return nil
        }
        guard let o = objects[key] as? [String: Any] else {
            return nil
        }
        self.init(o, objects: objects)
    }
}
