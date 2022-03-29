// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureProducts",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureProductsData",
            targets: ["FeatureProductsData"]
        ),
        .library(
            name: "FeatureProductsDomain",
            targets: ["FeatureProductsDomain"]
        )
    ],
    dependencies: [
        .package(
            name: "Mockingbird",
            url: "https://github.com/birdrides/mockingbird.git",
            .upToNextMinor(from: "0.20.0")
        ),
        .package(path: "../Network"),
        .package(path: "../NetworkErrors"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureProductsData",
            dependencies: [
                .product(name: "NabuNetworkError", package: "NetworkErrors"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                "FeatureProductsDomain"
            ]
        ),
        .target(
            name: "FeatureProductsDomain",
            dependencies: [
                .product(name: "NabuNetworkError", package: "NetworkErrors"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureProductsDataTests",
            dependencies: [
                .product(name: "NabuNetworkError", package: "NetworkErrors"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ToolKitMock", package: "Tool"),
                "FeatureProductsData",
                "Mockingbird"
            ],
            resources: [
                .process("Fixtures")
            ]
        ),
        .testTarget(
            name: "FeatureProductsDomainTests",
            dependencies: [
                .product(name: "NabuNetworkError", package: "NetworkErrors"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "ToolKitMock", package: "Tool"),
                "FeatureProductsDomain",
                "Mockingbird"
            ]
        )
    ]
)
