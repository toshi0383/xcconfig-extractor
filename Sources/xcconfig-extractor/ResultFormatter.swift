//
//  ResultFormatter.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

class ResultFormatter {
    let config: Config
    init(config: Config) {
        self.config = config
    }
    private func header(targetName: String?, configurationName: String?) -> [String] {
        let signature = "// Generated using xcconfig-extractor \(Config.version) by Toshihiro Suzuki - https://github.com/toshi0383/xcconfig-extractor"
        if config.isCocoaPods {
            if let targetName = targetName, let configurationName = configurationName?.lowercased() {
                let cocoapods = "#include \"../Pods/Target Support Files/Pods-\(targetName)/Pods-\(targetName).\(configurationName).xcconfig\""
                return [signature, cocoapods]
            }
        }
        return [signature]
    }
    func format(result: ResultObject, includes: [String] = []) -> [String] {
        return header(targetName: result.targetName, configurationName: result.configurationName)
            + includes.map {"#include \"\($0)\""} + result.settings + ["\n"]
    }
}
