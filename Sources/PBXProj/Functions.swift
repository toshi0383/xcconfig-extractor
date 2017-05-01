//
//  Functions.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

func findPaths(to id: String, objects: [String: Any]) -> [String] {
    for (k, v) in objects {
        if let o = v as? [String: Any], let group = Group(key: k, value: o, objects: objects) {
            if group.children.contains(id) {
                if let path = group.path {
                    return findPaths(to: k, objects: objects) + [path]
                } else {
                    return findPaths(to: k, objects: objects)
                }
            }
        }
    }
    return []
}
