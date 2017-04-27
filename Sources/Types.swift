//
//  Types.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

enum IsaType: String {
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

protocol IsaObject {
    var isa: IsaType { get }
    var object: [String: Any] { get }
}

extension IsaObject {
    var isa: IsaType {
        return IsaType(rawValue: object["isa"] as! String)!
    }
}
