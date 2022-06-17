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
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "DelegatedSelfCustodyKit",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "DelegatedSelfCustodyDataKit",
            dependencies: [
                .target(name: "DelegatedSelfCustodyKit"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "DelegatedSelfCustodyTests",
            dependencies: ["DelegatedSelfCustodyKit", "DelegatedSelfCustodyDataKit"]
        )
    ]
)
