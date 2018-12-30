import Commander
import Foundation
import PathKit
import Utilities
import xcodeproj

func write(to path: Path, lines: [String] = []) throws {
    let data = (lines.joined(separator: "\n") as NSString).data(using: String.Encoding.utf8.rawValue)!
    try path.write(data)
}

let main = command(
    Argument<Path>("PATH", description: "xcodeproj file", validator: dirExists),
    Argument<Path>("DIR", description: "Output directory of xcconfig files. Mkdirs if missing. Files are overwritten."),
    Flag("no-trim-duplicates", default: false, description: "Don't extract duplicated lines to common xcconfig files, simply map each buildSettings to one file."),
    Flag("no-edit-pbxproj", default: false, description: "Do not modify pbxproj at all."),
    Flag("include-existing", default: false, description: "`#include` already configured xcconfigs."),
    Flag("no-set-configurations", default: false, description: "Do not set xcconfig(baseConfigurationReference) in pbxproj. Ignored if `--no-edit-pbxproj` is true.")
) { xcodeprojPath, dirPath, isNoTrimDuplicates, isNoEdit, isIncludeExisting, isNoSetConfigurations in

    let pbxprojPath = xcodeprojPath + Path("project.pbxproj")
    guard pbxprojPath.isFile else {
        printStdError("pbxproj not exist!: \(pbxprojPath.string)")
        exit(1)
    }

    let projRoot = xcodeprojPath + ".."

    let dirPathComponents = dirPath.absolute().components

    // validate DIR
    guard dirPathComponents.starts(with: projRoot.absolute().components) else {
        printStdError("Invalid DIR parameter: \(dirPath.string)\nIt must be descendant of xcodeproj's root dir: \(projRoot.string)")
        exit(1)
    }

    if dirPath.isFile {
        printStdError("file already exists: \(dirPath.string)")
        exit(1)
    }
    if dirPath.isDirectory == false {
        try! dirPath.mkpath()
    }

    // config
    let config = Config(isIncludeExisting: isIncludeExisting)
    let formatter = ResultFormatter(config: config)

    //
    // read
    //

    guard let xcodeproj = try? XcodeProj(path: xcodeprojPath) else {
        printStdError("Failed to parse xcodeproj")
        exit(1)
    }

    let pbxproj = xcodeproj.pbxproj

    //
    // write
    //
    var baseResults = [ResultObject]()
    var targetResults = [ResultObject]()

    let configurations = pbxproj.buildConfigurations

    // base
    for configuration in configurations {
        let filePath = Path("\(dirPath.string)/\(configuration.name).xcconfig")
        let buildSettings = configuration.buildSettings
        let lines = convertToLines(buildSettings)
        let r = ResultObject(path: filePath, settings: lines, configurationName: configuration.name)
        if config.isIncludeExisting {
            if let fileref = configuration.baseConfiguration {
                let depth = (dirPath.components - projRoot.components).count
                let prefix: String = (0..<depth).map { _ in "../" }.joined()
                guard let fullPath = try fileref.fullPath(sourceRoot: projRoot) else {
                    fatalError("Could not establish fullPath for configuration file: \(fileref)")
                }
                r.includes = [prefix + fullPath.string]
            }
        }
        baseResults.append(r)
    }

    // targets
    let configurationNames = Set(configurations.map { c in c.name })
    for target in pbxproj.targets {
        let targetName = target.name

        guard let targetConfigurations = target.buildConfigurationList?.buildConfigurations else {
            printWarning("Target \(targetName) doesn't have any buildConfigurationList. Ignoring.")
            continue
        }

        for configuration in targetConfigurations {
            let filePath = Path("\(dirPath.string)/\(targetName)-\(configuration.name).xcconfig")
            let buildSettings = configuration.buildSettings
            let lines = convertToLines(buildSettings)

            let r = ResultObject(path: filePath, settings: lines, targetName: targetName, configurationName: configuration.name)
            if config.isIncludeExisting {
                if let fileref = configuration.baseConfiguration {
                    let depth = (dirPath.components - projRoot.components).count
                    let prefix: String = (0..<depth).map { _ in "../" }.joined()
                    guard let fullPath = try fileref.fullPath(sourceRoot: projRoot) else {
                        fatalError("Could not establish fullPath for configuration file: \(fileref)")
                    }
                    r.includes = [prefix + fullPath.string]
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
                .filter { $0.path.components.last!.contains("-\(configurationName).xcconfig") }
            let common: [String] = commonElements(filtered.map { $0.settings })
            let idx = baseResults.index { $0.configurationName == configurationName }!
            baseResults[idx].settings = distinctArray(common + baseResults[idx].settings)
            // Write Upper Layer Configs (e.g. App-Debug.xcconfig, AppTests-Debug.xcconfig)
            for r in filtered {
                let idx = targetResults.index(of: r)!
                targetResults[idx].settings = r.settings - common
            }
        }
        // Trim Duplicates in target configs (e.g. App-Debug.xcconfig and App-Release.xcconfig)
        for target in pbxproj.targets {
            let filtered = targetResults
                .filter { $0.path.components.last!.starts(with: "\(target.name)-") }
            let common: [String] = commonElements(filtered.map { $0.settings })
            let targetConfigPath = Path("\(dirPath.string)/\(target.name).xcconfig")
            let r = ResultObject(path: targetConfigPath, settings: common)
            try write(to: r.path, lines: formatter.format(result: r))
            for r in filtered {
                let idx = targetResults.index(of: r)!
                targetResults[idx].settings = r.settings - common
                targetResults[idx].includes += [targetConfigPath.lastComponent]
                try write(to: r.path, lines: formatter.format(result: targetResults[idx]))
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

    if isNoEdit {
        return
    }
    // Remove buildSettings from pbxproj and Setup xcconfigs
    let mainGroup = try! pbxproj.rootGroup()!

    let dirPathForGroup = dirPath.isAbsolute
        ? Path((dirPathComponents - projRoot.absolute().components).joined(separator: "/"))
        : dirPath

    let group = try mainGroup.addGroup(named: dirPathForGroup.string,
                                       options: [GroupAddingOptions.withoutFolder]).last!
    for file in try dirPath.children() {
        try group.addFile(at: file, sourceRoot: dirPath)
    }

    for configuration in configurations {

        configuration.buildSettings = [:]
        if isNoSetConfigurations {
            continue
        }
        if let fileref = pbxproj.fileReferences(named: "\(configuration.name).xcconfig").first  {
            if configuration.baseConfiguration != nil {
                if let existingPath = try configuration.baseConfiguration?.fullPath(sourceRoot: projRoot) {
                    printWarning("Replacing existing xcconfig: \(existingPath)")
                }
            }
            configuration.baseConfiguration = fileref
        } else {
            printStdError("Failed to locate xcconfig")
        }
    }
    for target in pbxproj.targets {
        for configuration in configurations {
            configuration.buildSettings = [:]
            if isNoSetConfigurations {
                continue
            }
            if let fileref = pbxproj.fileReferences(named: "\(target.name)-\(configuration.name).xcconfig").first {
                if configuration.baseConfiguration != nil {
                    if let existingPath = try configuration.baseConfiguration?.fullPath(sourceRoot: projRoot) {
                        printWarning("Replacing existing xcconfig: \(existingPath)")
                    }
                }
                configuration.baseConfiguration = fileref
            } else {
                printStdError("Failed to locate xcconfig")
            }
        }
    }
    do {
        try pbxproj.write(path: pbxprojPath, override: true)
    } catch {
        printStdError("Failed to save pbxproj.")
    }
}

main.run(Config.version)
