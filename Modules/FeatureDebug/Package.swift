// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureDebug",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureDebug", targets: ["FeatureDebugUI"]),
        .library(name: "FeatureDebugUI", targets: ["FeatureDebugUI"])
    ],
    dependencies: [
        .package(path: "../Tool"),
        .package(path: "../ComponentLibrary"),
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            from: "0.2.1"
        )
    ],
    targets: [
        .target(
            name: "FeatureDebugUI",
            dependencies: [
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Examples", package: "ComponentLibrary"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "FeatureDebugUITests",
            dependencies: [
                .target(name: "FeatureDebugUI")
            ]
        )
    ]
)
