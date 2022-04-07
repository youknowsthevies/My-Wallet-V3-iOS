// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureAuthentication",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureAuthentication",
            targets: ["FeatureAuthenticationData", "FeatureAuthenticationDomain", "FeatureAuthenticationUI"]
        ),
        .library(
            name: "FeatureAuthenticationUI",
            targets: ["FeatureAuthenticationUI"]
        ),
        .library(
            name: "FeatureAuthenticationDomain",
            targets: ["FeatureAuthenticationDomain"]
        ),
        .library(
            name: "FeatureAuthenticationMock",
            targets: ["FeatureAuthenticationMock"]
        )
    ],
    dependencies: [
        .package(
            name: "Zxcvbn",
            url: "https://github.com/oliveratkinson-bc/zxcvbn-ios.git",
            .branch("swift-package-manager")
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.18.0"
        ),
        .package(path: "../Analytics"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../HDWallet"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../NetworkErrors"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "FeatureAuthenticationDomain",
            dependencies: [
                .product(name: "HDWalletKit", package: "HDWallet"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "NetworkError", package: "NetworkErrors"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Zxcvbn", package: "Zxcvbn"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureAuthenticationData",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "NetworkError", package: "NetworkErrors"),
                .product(name: "NabuNetworkError", package: "NetworkErrors"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureAuthenticationUI",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableNavigation", package: "ComposableArchitectureExtensions"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureAuthenticationMock",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "WalletPayloadDataKit", package: "WalletPayload"),
                .product(name: "WalletPayloadKitMock", package: "WalletPayload")
            ]
        ),
        .testTarget(
            name: "FeatureAuthenticationDataTests",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationMock"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "WalletPayloadDataKit", package: "WalletPayload"),
                .product(name: "WalletPayloadKitMock", package: "WalletPayload"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "FeatureAuthenticationUITests",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationMock"),
                .target(name: "FeatureAuthenticationUI"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
