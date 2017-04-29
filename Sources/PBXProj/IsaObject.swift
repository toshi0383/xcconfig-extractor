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
}

public protocol IsaObject {
    var isa: IsaType { get }
    var object: [String: Any] { get }
}

extension IsaObject {
    public var isa: IsaType {
        return IsaType(rawValue: object["isa"] as! String)!
    }
}
