import Foundation
import PathKit

public func compare(_ l: Any, _ r: Any) -> Bool {
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

public func convertToLines(_ dictionary: [String: Any]) -> [String] {
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

public func commonElements<T: Equatable>(_ args: [T]...) -> [T] {
    return commonElements(args)
}
public func commonElements<T: Equatable>(_ args: [[T]]) -> [T] {
    if args.isEmpty {
        return []
    }
    var fst: [T] = args[0]
    for i in (0..<fst.count).reversed() {
        for cur in args.dropFirst() {
            if fst.isEmpty {
                return fst
            }
            if cur.contains(fst[i]) == false {
                fst.remove(at: i)
                break // this breaks only inner loop
            }
        }
    }
    return fst
}

public func distinctArray<T: Equatable>(_ array: [T]) -> [T] {
    var result: [T] = []
    for e in array  {
        if result.contains(e) == false {
            result.append(e)
        }
    }
    return result
}

// MARK: Operators
infix operator +|
public func +|<T: Equatable>(l: [T], r: [T]) -> [T] {
    var o = l
    o.append(contentsOf: r)
    return o
}
public func -<T: Equatable>(l: [T], r: [T]) -> [T] {
    return l.filter { t in r.contains(t) == false }
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
