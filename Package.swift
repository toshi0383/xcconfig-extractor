// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "xcconfig-extractor",
    dependencies: [
        .Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0),
        .Package(url: "https://github.com/kylef/PathKit.git", majorVersion: 0),
    ]
)
