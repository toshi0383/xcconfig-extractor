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
    var results = [ResultObject]()

    // base
    for configuration in pbxproj.rootObject.buildConfigurationList.buildConfigurations {
        let filePath = Path("\(dirPath.string)/Base-\(configuration.name).xcconfig")
        let buildSettings = configuration.buildSettings
        let lines = convertToLines(buildSettings)
        results.append(ResultObject(path: filePath, settings: lines))
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
            results.append(ResultObject(path: filePath, settings: lines))
        }
    }

    if isTrimDuplicates {
        let baseSettings: [String] = results.map { $0.settings }.reduce([]) { (acc: [String], values: [String]) -> [String] in
            if acc.isEmpty {
                return values
            } else {
                var r = acc
                for i in (0..<r.count).reversed() {
                    let v = r[i]
                    if values.contains(v) {
                        continue
                    } else {
                        r.remove(at: r.index(of: v)!)
                    }
                }
                return r
            }
        }
        for i in (0..<results.count) {
            var settings = results[i].settings - baseSettings
            results[i] = ResultObject(path: results[i].path, settings: settings)
        }
        let basexcconfig = "Base.xcconfig"
        results.append(ResultObject(path: Path("\(dirPath.string)/\(basexcconfig)"), settings: baseSettings))
        let formatted: [ResultObject] = results
            .map { r in
                (
                    r.path, r.path.components.last == basexcconfig ?
                        format(r.settings) :
                        format(r.settings, with: [basexcconfig])
                )
            }
            .map(ResultObject.init)
        for r in formatted {
            let data = (r.settings.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
            try r.path.write(data)
        }
    } else {
        let formatted: [ResultObject] = results
            .map { r in ( r.path, format(r.settings)) }
            .map(ResultObject.init)
        for r in formatted {
            let data = (r.settings.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
            try r.path.write(data)
        }
    }
}

main.run(version)
