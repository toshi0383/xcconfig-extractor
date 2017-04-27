//
//  PathKit+Commander.swift
//  xcconfig-extractor
//
//  Created by Toshihiro suzuki on 2017/04/27.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import Foundation

import Commander
import PathKit

extension Path : ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        guard let path = parser.shift() else {
            throw ArgumentError.missingValue(argument: nil)
        }
        self = Path(path)
    }
}
