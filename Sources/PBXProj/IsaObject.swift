//
//  IsaObject.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/29.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public enum IsaType: String {
    case XCConfigurationList
    case XCBuildConfiguration
    case PBXSourcesBuildPhase
    case PBXShellScriptBuildPhase
    case PBXResourcesBuildPhase
    case PBXProject
    case PBXNativeTarget
    case PBXGroup
    case PBXFrameworksBuildPhase
    case PBXBuildRule
    case PBXBuildFile
    case PBXFileReference
    case PBXContainerItemProxy
    case PBXVariantGroup
    case PBXTargetDependency
    case XCVersionGroup
    init(object: [String: Any]) {
        self.init(rawValue: object["isa"] as! String)!
    }
}

public protocol IsaObject {
    var key: String { get }
    var isa: IsaType { get }
    var rawObject: [String: Any] { get }
    init?(key: String, value: [String: Any], objects: [String: Any])
}

extension IsaObject {
    public var isa: IsaType {
        return IsaType(rawValue: rawObject["isa"] as! String)!
    }
}
