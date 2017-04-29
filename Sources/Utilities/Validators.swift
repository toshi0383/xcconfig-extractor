//
//  Validators.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

import Commander
import PathKit

public func checkPath(type: String, assertion: @escaping (Path) -> Bool) -> ((Path) throws -> Path) {
    return { (path: Path) throws -> Path in
        guard assertion(path) else { throw ArgumentError.invalidType(value: path.description, type: type, argument: nil) }
        return path
    }
}
public let pathExists = checkPath(type: "path") { $0.exists }
public let fileExists = checkPath(type: "file") { $0.isFile }
public let dirExists  = checkPath(type: "directory") { $0.isDirectory }

public let pathsExist = { (paths: [Path]) throws -> [Path] in try paths.map(pathExists) }
public let filesExist = { (paths: [Path]) throws -> [Path] in try paths.map(fileExists) }
public let dirsExist = { (paths: [Path]) throws -> [Path] in try paths.map(dirExists) }
