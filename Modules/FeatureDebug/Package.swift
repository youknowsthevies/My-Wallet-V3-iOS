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
        .package(
            name: "Pulse",
            url: "https://github.com/kean/Pulse.git",
            from: "0.20.0"
        ),
        .package(path: "../Tool"),
        .package(path: "../ComponentLibrary")
    ],
    targets: [
        .target(
            name: "FeatureDebugUI",
            dependencies: [
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Examples", package: "ComponentLibrary"),
                .product(name: "PulseUI", package: "Pulse")
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
