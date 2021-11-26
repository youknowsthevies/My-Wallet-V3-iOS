// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Metadata",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .library(
            name: "MetadataKit",
            targets: ["MetadataKit"]
        )
    ],
    dependencies: [
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "MetadataKit",
            dependencies: [
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "MetadataKitTests",
            dependencies: ["MetadataKit"]
        )
    ]
)
