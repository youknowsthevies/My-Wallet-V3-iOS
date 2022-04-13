// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureNFT",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureNFT",
            targets: ["FeatureNFTDomain", "FeatureNFTUI"]
        ),
        .library(
            name: "FeatureNFTUI",
            targets: ["FeatureNFTUI"]
        ),
        .library(
            name: "FeatureNFTDomain",
            targets: ["FeatureNFTDomain"]
        )
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.32.0"
        ),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../NetworkErrors"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureNFTDomain",
            dependencies: [
                .product(
                    name: "NetworkError",
                    package: "NetworkErrors"
                )
            ]
        ),
        .target(
            name: "FeatureNFTData",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "NabuNetworkError",
                    package: "NetworkErrors"
                )
            ]
        ),
        .target(
            name: "FeatureNFTUI",
            dependencies: [
                .target(name: "FeatureNFTDomain"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureNFTDataTests",
            dependencies: [
                .target(name: "FeatureNFTData")
            ]
        ),
        .testTarget(
            name: "FeatureNFTDomainTests",
            dependencies: [
                .target(name: "FeatureNFTDomain")
            ]
        ),
        .testTarget(
            name: "FeatureNFTUITests",
            dependencies: [
                .target(name: "FeatureNFTUI")
            ]
        )
    ]
)
