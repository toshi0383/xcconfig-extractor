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

let version = "0.2.0"
let header = ["// Generated using xcconfig-extractor \(version) by Toshihiro Suzuki - https://github.com/toshi0383/xcconfig-extractor"]

func write(to path: Path, settings: [String], includes: [String] = []) throws {
    let formatted = format(settings, with: includes)
    let data = (formatted.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
    try path.write(data)
}

func format(_ result: [String], with includes: [String] = []) -> [String] {
    return header + includes.map {"#include \"\($0)\""} + result + ["\n"]
}

class ResultObject: Equatable {
    let path: Path
    var settings: [String]
    let configurationName: String
    init(path: Path, settings: [String], configurationName: String) {
        self.path = path
        self.settings = settings
        self.configurationName = configurationName
    }
}
func ==(lhs: ResultObject, rhs: ResultObject) -> Bool {
    guard lhs.path == rhs.path else { return false }
    guard lhs.settings == rhs.settings else { return false }
    guard lhs.configurationName == rhs.configurationName else { return false }
    return true
}

let main = command(
    Argument<Path>("PATH", description: "xcodeproj file", validator: dirExists),
    Argument<Path>("DIR", description: "Output directory of xcconfig files. Mkdirs if missing. Files are overwritten."),
    Flag("trim-duplicates", description: "Extract duplicated lines to common xcconfig files.", default: true),
    Flag("no-edit-pbxproj", description: "Do not modify pbxproj.", default: false)
) { xcodeprojPath, dirPath, isTrimDuplicates, isNoEdit in

    let pbxprojPath = xcodeprojPath + Path("project.pbxproj")
    if dirPath.isDirectory == false {
        try! dirPath.mkpath()
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
        baseResults.append(ResultObject(path: filePath, settings: lines, configurationName: configuration.name))
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

            targetResults.append(ResultObject(path: filePath, settings: lines, configurationName: configuration.name))
        }
    }

    // Base.xcconfig
    if isTrimDuplicates {
        // Trim Duplicates in same configurationNames
        for configurationName in configurationNames {
            let filtered = targetResults
                .filter { $0.path.components.last!.contains(configurationName) }
            let common: [String] = commonElements(filtered.map { $0.settings })
            let configurationBase = baseResults.filter { $0.configurationName == configurationName }[0]
            let idx = baseResults.index(of: configurationBase)!
            baseResults[idx].settings = distinctArray(common + baseResults[idx].settings)
            // Write Upper Layer Configs (e.g. App-Debug.xcconfig, AppTests-Debug.xcconfig)
            for result in filtered {
                let settings = result.settings - common
                try write(to: result.path, settings: settings) // not including any other xcconfigs for targets'
            }
        }
        // Trim Duplicates in configurationName configs (e.g. Debug.xcconfig and Release.xcconfig)
        let commonBetweenConfigurationBases = commonElements(baseResults.map { $0.settings })
        // Write Configuration Base Configs (e.g. Debug.xcconfig, Release.xcconfig)
        for result in baseResults {
            let settings = result.settings - commonBetweenConfigurationBases
            try write(to: result.path, settings: settings, includes: ["Base.xcconfig"])
        }
        // Finally Write Base.xcconfig
        let basexcconfig = Path("\(dirPath.string)/Base.xcconfig")
        try write(to: basexcconfig, settings: commonBetweenConfigurationBases)
    } else {
        for r in (baseResults + targetResults) {
            try write(to: r.path, settings: r.settings)
        }
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

main.run(version)
