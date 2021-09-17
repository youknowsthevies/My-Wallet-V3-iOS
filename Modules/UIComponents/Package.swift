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
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "UIComponentsKit",
            path: "UIComponentsKit",
            resources: [.process("Fonts")]
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
