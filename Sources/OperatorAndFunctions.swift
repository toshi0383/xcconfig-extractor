//
//  OperatorAndFunctions.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import PathKit

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

func write(to path: Path, settings: [String], includes: [String] = []) throws {
    let formatted = format(settings, with: includes)
    let data = (formatted.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
    try path.write(data)
}

func commonElements<T: Hashable>(_ args: [T]...) -> [T] {
    return commonElements(args)
}
func commonElements<T: Hashable>(_ args: [[T]]) -> [T] {
    var results: [T] = []
    for i in (1..<args.count) {
        let fst = args[i-1]
        let snd = args[i]
        for l in fst {
            for r in snd {
                if l == r, !results.contains(l) {
                    results.append(l)
                }
            }
        }
    }
    return results
}

// MARK: Operators
infix operator +|
func +|<T: Equatable>(l: [T], r: [T]) -> [T] {
    var o = l
    o.append(contentsOf: r)
    return o
}
func -<T: Equatable>(l: [T], r: [T]) -> [T] {
    return l.filter { t in r.contains(t) == false }
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
