// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "xcconfig-extractor",
    products: [
        .executable(name: "xcconfig-extractor", targets: ["xcconfig-extractor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
        .package(url: "https://github.com/kylef/Commander", from: "0.9.0"),
        .package(url: "https://github.com/tuist/XcodeProj", from: "7.0.1"),
    ],
    targets: [
        .target(name: "xcconfig-extractor", dependencies: ["Utilities", "PathKit", "Commander", "XcodeProj"]),
        .target(name: "Utilities", dependencies: ["XcodeProj", "PathKit", "Commander"]),
        .testTarget(name: "UtilitiesTests", dependencies: ["Utilities"]),
    ]
)
