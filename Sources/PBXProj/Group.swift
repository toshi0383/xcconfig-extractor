//
//  Group.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public struct Group: IsaObject {
    public let rawObject: [String : Any]
    public let key: String
    public let children: [String]
    public let path: String?
    public let name: String?
    public init?(key: String, value o: [String : Any], objects: [String : Any]) {
        guard IsaType(object: o) == .PBXGroup else {
            return nil
        }
        self.key = key
        self.rawObject = o
        self.children = o["children"] as! [String]
        self.path = o["path"] as? String
        self.name = o["name"] as? String
    }
}
