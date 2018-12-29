import Foundation
import xcodeproj

extension PBXProj {
    public var targets: [PBXNativeTarget] {
        return nativeTargets
    }

    public func fileReferences(named nameOrPath: String) -> [PBXFileReference] {
        return groups.map { $0.file(named: nameOrPath) }.compactMap { $0 }
    }
}
