//
//  NativeTarget.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

public enum ProductType: String {
    case application = "com.apple.product-type.application"
    case unitTest = "com.apple.product-type.bundle.unit-test"
    case framework = "com.apple.product-type.framework"
    case uiTesting = "com.apple.product-type.bundle.ui-testing"
    case tool = "com.apple.product-type.tool"
}

public struct NativeTarget: IsaObject {
    public let key: String
    public let rawObject: [String: Any]

    public let name: String
    public let productName: String
    public let productType: ProductType
    public let buildRules: [Any]? // TODO
    public let productReference: String
    public let dependencies: [Any] // TODO
    public let buildPhases: [String] // TODO
    public let buildConfigurationList: BuildConfigurationList
    public init?(key: String, value o: [String: Any], objects: [String: Any]) {
        guard IsaType(object: o) == .PBXNativeTarget else {
            return nil
        }
        self.key = key
        self.rawObject = o
        self.name = o["name"] as! String
        self.productName = o["productName"] as! String
        self.productType = ProductType(rawValue: o["productType"] as! String)!
        self.buildRules = o["buildRules"] as? [Any]
        self.productReference = o["productReference"] as! String
        self.dependencies = o["dependencies"] as! [Any]
        self.buildPhases = o["buildPhases"] as! [String]
        let buildConfigurationListKey = o["buildConfigurationList"] as! String
        self.buildConfigurationList = BuildConfigurationList(key: buildConfigurationListKey, objects: objects)!
    }
}
