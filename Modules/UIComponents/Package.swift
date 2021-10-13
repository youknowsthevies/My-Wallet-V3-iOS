// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponentsKit"]
        )
    ],
    dependencies: [
        .package(
            name: "Lottie",
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.2.0"
        ),
        .package(
            name: "Nuke",
            url: "https://github.com/kean/Nuke.git",
            from: "10.3.1"
        ),
        .package(
            name: "NukeUI",
            url: "https://github.com/kean/NukeUI.git",
            from: "0.6.5"
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
        .package(
            name: "swift-case-paths",
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.7.0"
        ),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "UIComponentsKit",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "Lottie", package: "Lottie"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "NukeUI"),
                .product(name: "ToolKit", package: "Tool")
            ],
            path: "UIComponentsKit",
            resources: [
                .process("Fonts")
            ]
        ),
        .testTarget(
            name: "UIComponentsKitTests",
            dependencies: [
                "UIComponentsKit",
                .product(name: "SnapshotTesting", package: "SnapshotTesting")
            ],
            path: "UIComponentsKitTests",
            exclude: ["__Snapshots__"]
        )
    ]
)
