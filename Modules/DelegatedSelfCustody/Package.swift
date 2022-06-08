// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DelegatedSelfCustody",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "DelegatedSelfCustodyKit",
            targets: ["DelegatedSelfCustodyKit", "DelegatedSelfCustodyDataKit"]
        )
    ],
    dependencies: [
        .package(path: "../Tool"),
        .package(path: "../Network")
    ],
    targets: [
        .target(
            name: "DelegatedSelfCustodyKit",
            dependencies: [
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "DelegatedSelfCustodyDataKit",
            dependencies: [
                .target(name: "DelegatedSelfCustodyKit"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .testTarget(
            name: "DelegatedSelfCustodyTests",
            dependencies: ["DelegatedSelfCustodyKit", "DelegatedSelfCustodyDataKit"]
        )
    ]
)
