// swift-tools-version:5.3

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
            from: "0.32.0"
        ),
        .package(path: "../BlockchainComponentLibrary")
    ],
    targets: [
        .target(
            name: "FeatureCoinDomain",
            dependencies: [
            ]
        ),
        .target(
            name: "FeatureCoinData",
            dependencies: [
                .target(name: "FeatureCoinDomain")
            ]
        ),
        .target(
            name: "FeatureCoinUI",
            dependencies: [
                .target(name: "FeatureCoinDomain"),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .testTarget(
            name: "FeatureCoinDomainTests",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "FeatureCoinDataTests",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "FeatureCoinUITests",
            dependencies: [
            ]
        )
    ]
)
