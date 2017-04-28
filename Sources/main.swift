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

let version = "0.2.0"
let header = ["// Generated using xcconfig-extractor \(version) by Toshihiro Suzuki - https://github.com/toshi0383/xcconfig-extractor"]

class ResultObject {
    let path: Path
    var settings: [String]
    init(path: Path, settings: [String]) {
        self.path = path
        self.settings = settings
    }
}

let main = command(
    Argument<Path>("PATH", description: "xcodeproj file", validator: dirExists),
    Argument<Path>("DIR", description: "output directory"),
    Flag("trim-duplicates", description: "extract duplicated lines to common xcconfigs.", default: true)
) { pbxprojPath, dirPath, isTrimDuplicates in

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
    var baseResults = [ResultObject]()
    var targetResults = [ResultObject]()

    // base
    for configuration in pbxproj.rootObject.buildConfigurationList.buildConfigurations {
        let filePath = Path("\(dirPath.string)/\(configuration.name).xcconfig")
        let buildSettings = configuration.buildSettings
        let lines = convertToLines(buildSettings)
        baseResults.append(ResultObject(path: filePath, settings: lines))
    }

    // targets
    let configurations = pbxproj.rootObject.targets.flatMap { t in
        t.buildConfigurationList.buildConfigurations
    }
    let configurationNames = Set(configurations.map { c in c.name })
    for target in pbxproj.rootObject.targets {
        let targetName = target.name
        for configuration in target.buildConfigurationList.buildConfigurations {
            let filePath = Path("\(dirPath.string)/\(targetName)-\(configuration.name).xcconfig")
            let buildSettings = configuration.buildSettings
            let lines = convertToLines(buildSettings)
            targetResults.append(ResultObject(path: filePath, settings: lines))
        }
    }

    // Base.xcconfig
    if isTrimDuplicates {
        let allResults = baseResults + targetResults
        let baseSettings: [String] = allResults.map { $0.settings }.reduce([], filterCommon)

        // Trim lines from each resultss
        for i in (0..<baseResults.count) {
            var settings = baseResults[i].settings - baseSettings
            baseResults[i] = ResultObject(path: baseResults[i].path, settings: settings)
        }
        for i in (0..<targetResults.count) {
            var settings = targetResults[i].settings - baseSettings
            targetResults[i] = ResultObject(path: targetResults[i].path, settings: settings)
        }
        // Write Base.xcconfig
        let basexcconfig = Path("\(dirPath.string)/Base.xcconfig")
        try write(to: basexcconfig, settings: baseSettings)

        // Trim Duplicates in same configurationNames
        for configurationName in configurationNames {
            let filtered = (baseResults + targetResults)
                .filter { $0.path.components.last!.contains(configurationName) }
            let common = filtered.map { $0.settings }.reduce([], filterCommon)
            try write(to: Path("\(dirPath)/\(configurationName)-Base.xcconfig"), settings: common, includes: ["Base.xcconfig"])
            for result in filtered {
                let settings = result.settings - common
                if result.path.components.last == "\(configurationName).xcconfig" {
                    try write(to: result.path, settings: settings, includes: ["\(configurationName)-Base.xcconfig"])
                } else {
                    try write(to: result.path, settings: settings)
                }
            }
        }
    } else {
        let formatted: [ResultObject] = (baseResults + targetResults)
            .map { r in ( r.path, format(r.settings)) }
            .map(ResultObject.init)
        for r in formatted {
            let data = (r.settings.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
            try r.path.write(data)
        }
    }
}

main.run(version)
