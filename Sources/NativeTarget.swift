//
//  NativeTarget.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

enum ProductType: String {
    case application = "com.apple.product-type.application"
    case unitTest = "com.apple.product-type.bundle.unit-test"
    case framework = "com.apple.product-type.framework"
    case uiTesting = "com.apple.product-type.bundle.ui-testing"
}

struct NativeTarget: IsaObject {
    let object: [String: Any]

    let name: String
    let productName: String
    let productType: ProductType
    let buildRules: [Any]? // TODO
    let productReference: String
    let dependencies: [Any] // TODO
    let buildPhases: [String] // TODO
    let buildConfigurationList: BuildConfigurationList
    init(target o: [String: Any], objects: [String: Any]) {
        self.object = o
        self.name = o["name"] as! String
        self.productName = o["productName"] as! String
        self.productType = ProductType(rawValue: o["productType"] as! String)!
        self.buildRules = o["buildRules"] as? [Any]
        self.productReference = o["productReference"] as! String
        self.dependencies = o["dependencies"] as! [Any]
        self.buildPhases = o["buildPhases"] as! [String]
        let buildConfigurationListKey = o["buildConfigurationList"] as! String
        self.buildConfigurationList = BuildConfigurationList(objects[buildConfigurationListKey] as! [String: Any], objects: objects)
    }
}
