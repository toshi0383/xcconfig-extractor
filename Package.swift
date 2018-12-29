// swift-tools-version:4.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "xcconfig-extractor",
    products: [
        .executable(name: "xcconfig-extractor", targets: ["xcconfig-extractor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "0.9.2"),
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/tuist/xcodeproj", from: "6.3.0"),
    ],
    targets: [
        .target(name: "xcconfig-extractor", dependencies: ["Utilities", "PathKit", "Commander", "xcodeproj"]),
        .target(name: "Utilities", dependencies: ["xcodeproj", "PathKit", "Commander"]),
        .testTarget(name: "UtilitiesTests", dependencies: ["Utilities"]),
    ]
)
