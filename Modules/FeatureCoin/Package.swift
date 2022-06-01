// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "FeatureCoin",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "FeatureCoin", targets: [
            "FeatureCoinDomain",
            "FeatureCoinUI",
            "FeatureCoinData"
        ]),
        .library(name: "FeatureCoinDomain", targets: ["FeatureCoinDomain"]),
        .library(name: "FeatureCoinUI", targets: ["FeatureCoinUI"]),
        .library(name: "FeatureCoinData", targets: ["FeatureCoinData"])
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.34.0"
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.9.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../Money"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Tool"),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "FeatureCoinDomain",
            dependencies: [
                .product(
                    name: "MoneyKit",
                    package: "Money"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "BlockchainNamespace",
                    package: "BlockchainNamespace"
                )
            ]
        ),
        .target(
            name: "FeatureCoinData",
            dependencies: [
                .target(
                    name: "FeatureCoinDomain"
                ),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "MoneyKit",
                    package: "Money"
                )
            ]
        ),
        .target(
            name: "FeatureCoinUI",
            dependencies: [
                .target(name: "FeatureCoinDomain"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "BlockchainNamespace",
                    package: "BlockchainNamespace"
                ),
                .product(
                    name: "AnalyticsKit",
                    package: "Analytics"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "ToolKit",
                    package: "Tool"
                ),
                .product(
                    name: "MoneyKit",
                    package: "Money"
                ),
                .product(
                    name: "Errors",
                    package: "Errors"
                ),
                .product(
                    name: "ComposableArchitectureExtensions",
                    package: "ComposableArchitectureExtensions"
                )
            ]
        ),
        .testTarget(
            name: "FeatureCoinDomainTests",
            dependencies: [
                .target(name: "FeatureCoinDomain"),
                .product(
                    name: "TestKit",
                    package: "Test"
                )
            ]
        ),
        .testTarget(
            name: "FeatureCoinDataTests",
            dependencies: [
                .target(name: "FeatureCoinData")
            ]
        ),
        .testTarget(
            name: "FeatureCoinUITests",
            dependencies: [
                .target(name: "FeatureCoinUI"),
                .product(name: "SnapshotTesting", package: "SnapshotTesting")
            ],
            exclude: [
                "CoinView/__Snapshots__"
            ]
        )
    ]
)
