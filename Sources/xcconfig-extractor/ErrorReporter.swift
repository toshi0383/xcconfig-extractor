//
//  ErrorReporter.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

func printStdError(_ message: String) {
    fputs("\(ANSI.red)\(message)\(ANSI.reset)\n", stderr)
}

func printWarning(_ message: String) {
    fputs("\(ANSI.yellow)\(message)\(ANSI.reset)\n", stdout)
}

private enum ANSI : String, CustomStringConvertible {
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"

    case bold = "\u{001B}[0;1m"
    case reset = "\u{001B}[0;0m"

    var description:String {
        if isatty(STDOUT_FILENO) > 0 {
            return rawValue
        }
        return ""
    }
}

