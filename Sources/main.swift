//
//  main.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import Commander
import PathKit

let version = "1.0.0"

let main = command(
    Argument<Path>("PATH", description: "xcodeproj file", validator: dirExists),
    Argument<Path>("DIR", description: "output directory")
) { pbxprojPath, dirPath in
    let path = pbxprojPath + Path("project.pbxproj")
    if dirPath.isDirectory == false {
        try! dirPath.mkdir()
    }

    // read
    let data: Data = try path.read()
    guard let pbxproj = Pbxproj(data: data) else {
        fatalError("Failed to parse Pbxproj")
    }

    // write
    let configurations = pbxproj.targets.flatMap { t in
        t.buildConfigurations
    }
    let configurationNames = Set(configurations.map { c in c.name })
    var eachCommonSettings = [String: [String: Any]]()
    for name in configurationNames {
        let configurationsForName = configurations.filter { $0.name == name }
        var common = [String: Any]()
        for c in configurationsForName {
            if common.isEmpty {
                common = c.buildSettings
            } else {
                for (k, v) in c.buildSettings {
                    if let commonV = common[k], compare(commonV, v) {
                        // stay
                    } else {
                        // remove
                        common.removeValue(forKey: k)
                    }
                }
            }
        }
        eachCommonSettings[name] = common
    }
    var baseCommonSettings = [String: Any]()
    for (key, v) in eachCommonSettings {
        if baseCommonSettings.isEmpty {
            baseCommonSettings = v
        } else {
            for (kk, vv) in v {
                if let commonV = baseCommonSettings[kk], compare(commonV, vv) {
                    // stay on base, remove from each
                    for keyy in eachCommonSettings.keys {
                        eachCommonSettings[keyy]!.removeValue(forKey: kk)
                    }
                } else {
                    // remove from base
                    baseCommonSettings.removeValue(forKey: kk)
                }
            }
        }
    }
    for v in eachCommonSettings {
        print("==========================")
        print(v)
    }
    print("==========================")
    print(baseCommonSettings)

//    for (k, v) in taerget {
//        print("\(k): \(v)")
//        switch v {
//        case is NSString:
//        case is NSInteger:
//            // Integer need to be parsed before Bool
//        case is Bool:
//        case is Date:
//        case is Data:
//        case is NSArray:
//        case is [String: Any]:
//        default:
//        }
//    }
}

main.run(version)
