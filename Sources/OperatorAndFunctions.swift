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

func convertToLines(_ dictionary: [String: Any]) -> [String] {
    let result = dictionary.map { (k, v) -> String in
        switch v {
        case let s as String:
            return "\(k) = \(s)"
        case let s as [String]:
            return "\(k) = \(s.map{$0}.joined(separator: " "))"
        case is [String: Any]:
            fatalError("Unexpected Object. Please file an issue if you believe this as a bug.")
        default:
            fatalError("Unexpected Object. Please file an issue if you believe this as a bug.")
        }
    }
    return result
}

func format(_ result: [String], with includes: [String] = []) -> [String] {
    return header + includes.map {"#include \"\($0)\""} + result + ["\n"]
}

// MARK: Operators
func -<T: Equatable>(l: [T], r: [T]) -> [T] {
    return l.filter { t in r.contains(t) == false }
}
