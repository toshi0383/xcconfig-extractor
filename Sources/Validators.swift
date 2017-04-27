//
//  Validators.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

import Commander
import PathKit

func checkPath(type: String, assertion: @escaping (Path) -> Bool) -> ((Path) throws -> Path) {
    return { (path: Path) throws -> Path in
        guard assertion(path) else { throw ArgumentError.invalidType(value: path.description, type: type, argument: nil) }
        return path
    }
}
let pathExists = checkPath(type: "path") { $0.exists }
let fileExists = checkPath(type: "file") { $0.isFile }
let dirExists  = checkPath(type: "directory") { $0.isDirectory }

let pathsExist = { (paths: [Path]) throws -> [Path] in try paths.map(pathExists) }
let filesExist = { (paths: [Path]) throws -> [Path] in try paths.map(fileExists) }
let dirsExist = { (paths: [Path]) throws -> [Path] in try paths.map(dirExists) }
