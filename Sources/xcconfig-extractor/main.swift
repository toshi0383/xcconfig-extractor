//
//  main.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation
import Commander
import PathKit
import PBXProj
import Utilities

func write(to path: Path, lines: [String] = []) throws {
    let data = (lines.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
    try path.write(data)
}

let main = command(
    Argument<Path>("PATH", description: "xcodeproj file", validator: dirExists),
    Argument<Path>("DIR", description: "Output directory of xcconfig files. Mkdirs if missing. Files are overwritten."),
    Flag("no-trim-duplicates", description: "Don't extract duplicated lines to common xcconfig files, simply map each buildSettings to one file.", default: false),
    Flag("no-edit-pbxproj", description: "Do not modify pbxproj.", default: false),
    Flag("include-existing", description: "`#include` already configured xcconfigs.", default: true)
) { xcodeprojPath, dirPath, isNoTrimDuplicates, isNoEdit, isIncludeExisting in

    let pbxprojPath = xcodeprojPath + Path("project.pbxproj")
    if dirPath.isDirectory == false {
        try! dirPath.mkpath()
    }

    // config
    let config = Config(isIncludeExisting: isIncludeExisting)
    let projRoot = xcodeprojPath + ".."
    let formatter = ResultFormatter(config: config)

    // validate DIR
    guard projRoot.contains(dirPath) else {
        print("Invalid DIR parameter: \(dirPath.string)\nIt must be descendant of xcodeproj's root dir: \(projRoot.string)")
        exit(1)
    }

    //
    // read
    //
    let data: Data = try pbxprojPath.read()
    guard let pbxproj = Pbxproj(data: data) else {
        fatalError("Failed to parse Pbxproj")
    }

    //
    // write
    //
    var baseResults = [ResultObject]()
    var targetResults = [ResultObject]()

    // base
    for configuration in pbxproj.rootObject.buildConfigurationList.buildConfigurations {
        let filePath = Path("\(dirPath.string)/\(configuration.name).xcconfig")
        let buildSettings = configuration.buildSettings
        let lines = convertToLines(buildSettings)
        let r = ResultObject(path: filePath, settings: lines, configurationName: configuration.name)
        if config.isIncludeExisting {
            if let fileref = configuration.baseConfigurationReference {
                let depth = (dirPath.components - projRoot.components).count
                let prefix = (0..<depth).reduce("") { $0.0 + "../" }
                r.includes = [prefix + fileref.fullPath]
            }
        }
        baseResults.append(r)
    }

    // targets
    let configurations = pbxproj.rootObject.buildConfigurationList.buildConfigurations
    let configurationNames = Set(configurations.map { c in c.name })
    for target in pbxproj.rootObject.targets {
        let targetName = target.name
        for configuration in target.buildConfigurationList.buildConfigurations {
            let filePath = Path("\(dirPath.string)/\(targetName)-\(configuration.name).xcconfig")
            let buildSettings = configuration.buildSettings
            let lines = convertToLines(buildSettings)

            let r = ResultObject(path: filePath, settings: lines, targetName: targetName, configurationName: configuration.name)
            if config.isIncludeExisting {
                if let fileref = configuration.baseConfigurationReference {
                    let depth = (dirPath.components - projRoot.components).count
                    let prefix = (0..<depth).reduce("") { $0.0 + "../" }
                    r.includes = [prefix + fileref.fullPath]
                }
            }
            targetResults.append(r)
        }
    }

    // Base.xcconfig
    if isNoTrimDuplicates {
        for r in (baseResults + targetResults) {
            try write(to: r.path, lines: formatter.format(result: r))
        }
    } else {
        // Trim Duplicates in same configurationNames
        for configurationName in configurationNames {
            let filtered = targetResults
                .filter { $0.path.components.last!.contains(configurationName) }
            let common: [String] = commonElements(filtered.map { $0.settings })
            let configurationBase = baseResults.filter { $0.configurationName == configurationName }[0]
            let idx = baseResults.index(of: configurationBase)!
            baseResults[idx].settings = distinctArray(common + baseResults[idx].settings)
            // Write Upper Layer Configs (e.g. App-Debug.xcconfig, AppTests-Debug.xcconfig)
            for r in filtered {
                r.settings = r.settings - common
                try write(to: r.path, lines: formatter.format(result: r)) // not including any other xcconfigs for targets'
            }
        }
        // Trim Duplicates in configurationName configs (e.g. Debug.xcconfig and Release.xcconfig)
        let common = commonElements(baseResults.map { $0.settings })
        // Write Configuration Base Configs (e.g. Debug.xcconfig, Release.xcconfig)
        for r in baseResults {
            r.settings = r.settings - common
            try write(to: r.path, lines: formatter.format(result: r, includes: ["Base.xcconfig"]))
        }
        // Finally Write Base.xcconfig
        let r = ResultObject(path: Path("\(dirPath.string)/Base.xcconfig"), settings: common)
        try write(to: r.path, lines: formatter.format(result: r))
    }

    // Remove buildSettings from pbxproj
    if isNoEdit {
        return
    }

    let contents: String = try pbxprojPath.read()

    var result: [String] = []
    var skip = false
    let tabs = "\t\t\t"
    let spaces = "         "
    for line in contents.characters.split(separator: "\n", omittingEmptySubsequences: false) {
        let l = String(line)
        if l == "\(tabs)buildSettings = {" || l == "\(spaces)buildSettings = {" {
            result.append(l)
            skip = true
        } else if skip == true && (l == "\(tabs)};" || l == "\(spaces)};") {
            result.append(l)
            skip = false
        } else if skip == false {
            result.append(l)
        }
    }
    try pbxprojPath.write(result.joined(separator: "\n"))
}

main.run(Config.version)
