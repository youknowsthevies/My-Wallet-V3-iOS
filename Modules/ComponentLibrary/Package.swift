// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ComponentLibrary",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "ComponentLibrary",
            targets: [
                "ComponentLibrary"
            ]
        ),
        .library(
            name: "Examples",
            targets: [
                "Examples"
            ]
        )
    ],
    dependencies: [
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        )
    ],
    targets: [
        .target(
            name: "ComponentLibrary",
            dependencies: []
        ),
        .testTarget(
            name: "ComponentLibraryTests",
            dependencies: [
                "ComponentLibrary",
                "SnapshotTesting",
                "Examples"
            ],
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "Examples",
            dependencies: [
                "ComponentLibrary"
            ]
        )
    ]
)
