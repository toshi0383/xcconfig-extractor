//
//  OperatorAndFunctions.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
func compare(_ l: Any, _ r: Any) -> Bool {
    switch l {
    case let ls as String:
        if let rs = r as? String {
            return ls == rs
        } else {
            return false
        }
    case let ls as [String: Any]:
        if let rs = r as? [String: Any] {
            return ls == rs
        } else {
            return false
        }
    case let ls as [Any]:
        if let rs = r as? [Any] {
            guard ls.count == rs.count else { return false }
            for i in (0..<ls.count).map({ $0 }) {
                if compare(ls[i], rs[i]) == false {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    default:
        return false
    }
}
