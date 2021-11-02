// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureWithdrawalLock",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureWithdrawalLock", targets: ["FeatureWithdrawalLockDomain", "FeatureWithdrawalLockUI"]),
        .library(name: "FeatureWithdrawalLockDomain", targets: ["FeatureWithdrawalLockDomain"]),
        .library(name: "FeatureWithdrawalLockUI", targets: ["FeatureWithdrawalLockUI"])
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.28.1"
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(path: "../ComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../UIComponents"),
        .package(path: "../Network"),
        .package(path: "../NetworkErrors"),
        .package(path: "../Platform")
    ],
    targets: [
        .target(
            name: "FeatureWithdrawalLockDomain",
            dependencies: [
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "NetworkErrors",
                    package: "NetworkErrors"
                ),
                .product(
                    name: "DIKit",
                    package: "DIKit"
                ),
                .product(
                    name: "PlatformKit",
                    package: "Platform"
                )
            ]
        ),
        .target(
            name: "FeatureWithdrawalLockUI",
            dependencies: [
                .target(name: "FeatureWithdrawalLockDomain"),
                .product(
                    name: "DIKit",
                    package: "DIKit"
                ),
                .product(
                    name: "ComponentLibrary",
                    package: "ComponentLibrary"
                ),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "ComposableNavigation",
                    package: "ComposableArchitectureExtensions"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "UIComponents",
                    package: "UIComponents"
                )
            ]
        ),
        .testTarget(
            name: "FeatureWithdrawalLockDomainTests",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "FeatureWithdrawalLockUITests",
            dependencies: [
            ]
        )
    ]
)
