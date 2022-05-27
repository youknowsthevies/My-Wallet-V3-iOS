// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Observability",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "ObservabilityKit",
            targets: ["ObservabilityKit"]
        )
    ],
    dependencies: [
        .package(name: "Tool", path: "../Tool")
    ],
    targets: [
        .target(
            name: "ObservabilityKit",
            dependencies: [
                .product(name: "ToolKit", package: "Tool")
            ]
        )
    ]
)
