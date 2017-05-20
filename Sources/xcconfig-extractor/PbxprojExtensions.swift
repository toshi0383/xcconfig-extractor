//
//  PbxprojExtensions.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/05/20.
//
//

import Foundation
import AsciiPlistParser

extension Object {
    var dictionary: [String: Any]  {
        var r = [String: Any]()
        for (keyref, value) in self {
            switch value {
            case let v as StringValue:
                r[keyref.value] = v.value
            case let v as ArrayValue:
                r[keyref.value] = v.value
            case let v as Object:
                r[keyref.value] = v.dictionary
            default:
                fatalError("Failed to convert Object to [String: Any]")
            }
        }
        return r
    }
}
