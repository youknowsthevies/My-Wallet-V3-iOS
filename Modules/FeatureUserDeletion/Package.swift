// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureUserDeletion",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "FeatureUserDeletionData",
            targets: ["FeatureUserDeletionData"]
        ),
        .library(
            name: "FeatureUserDeletionDomain",
            targets: ["FeatureUserDeletionDomain"]
        ),
        .library(
            name: "FeatureUserDeletionUI",
            targets: ["FeatureUserDeletionUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.34.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../NetworkErrors"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureUserDeletionData",
            dependencies: [
                .product(name: "NetworkErrors", package: "NetworkErrors"),
                .product(name: "NetworkKit", package: "Network"),
//                .product(name: "ToolKit", package: "Tool"),
                "FeatureUserDeletionDomain"
            ]
        ),
        .target(
            name: "FeatureUserDeletionDomain",
            dependencies: [
                .product(name: "NetworkErrors", package: "NetworkErrors")
//                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureUserDeletionUI",
            dependencies: [
                .product(
                    name: "AnalyticsKit",
                    package: "Analytics"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                ),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "ComposableArchitectureExtensions",
                    package: "ComposableArchitectureExtensions"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "PlatformKit",
                    package: "Platform"
                ),
                .product(
                    name: "UIComponents",
                    package: "UIComponents"
                )
//                .product(name: "NetworkErrors", package: "NetworkErrors"),
//                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureUserDeletionDataTests",
            dependencies: [
                //                .product(name: "NetworkErrors", package: "NetworkErrors"),
//                .product(name: "TestKit", package: "Test"),
//                .product(name: "ToolKit", package: "Tool"),
//                .product(name: "ToolKitMock", package: "Tool"),
                "FeatureUserDeletionData"
            ],
            resources: [
                //                .process("Fixtures")
            ]
        ),
        .testTarget(
            name: "FeatureUserDeletionDomainTests",
            dependencies: [
                //                .product(name: "NetworkErrors", package: "NetworkErrors"),
//                .product(name: "TestKit", package: "Test"),
//                .product(name: "ToolKit", package: "Tool"),
//                .product(name: "ToolKitMock", package: "Tool"),
                "FeatureUserDeletionDomain"
            ]
        ),
        .testTarget(
            name: "FeatureUserDeletionUITests",
            dependencies: [
                "FeatureUserDeletionData",
                "FeatureUserDeletionDomain",
                "FeatureUserDeletionUI"
            ]
        )
    ]
)
