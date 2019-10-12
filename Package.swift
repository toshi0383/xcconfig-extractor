// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "xcconfig-extractor",
    products: [
        .executable(name: "xcconfig-extractor", targets: ["xcconfig-extractor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/kylef/Commander", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/tuist/XcodeProj", .upToNextMajor(from: "7.1.0")),
    ],
    targets: [
        .target(name: "xcconfig-extractor", dependencies: ["Utilities", "PathKit", "Commander", "XcodeProj"]),
        .target(name: "Utilities", dependencies: ["XcodeProj", "PathKit", "Commander"]),
        .testTarget(name: "UtilitiesTests", dependencies: ["Utilities"]),
    ]
)
