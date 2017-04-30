//
//  XCConfigExtractorError.swift
//  xcconfig-extractor
//
//  Created by Toshihiro Suzuki on 2017/04/30.
//  Copyright © 2017 Toshihiro Suzuki. All rights reserved.
//

import Foundation

struct XCConfigExtractorError: Error {
    private let message: String
    init(_ message: String) {
        self.message = message
    }
}
