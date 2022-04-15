// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureNotificationSettings",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "FeatureNotificationSettings", targets: [
            "FeatureNotificationSettingsDomain",
            "FeatureNotificationSettingsUI",
            "FeatureNotificationSettingsData"
        ]),
        .library(name: "FeatureNotificationSettingsDomain", targets: ["FeatureNotificationSettingsDomain"]),
        .library(name: "FeatureNotificationSettingsUI", targets: ["FeatureNotificationSettingsUI"]),
        .library(name: "FeatureNotificationSettingsData", targets: ["FeatureNotificationSettingsData"])
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.34.0"
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(path: "../Analytics"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../ComposableArchitectureExtensions"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../NetworkErrors"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureNotificationSettingsDomain",
            dependencies: [
                .product(
                    name: "NetworkError",
                    package: "NetworkErrors"
                ),
                .product(
                    name: "Localization",
                    package: "Localization"
                ),
                .product(
                    name: "DIKit",
                    package: "DIKit"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
                )
            ],
            path: "Sources/NotificationSettings/NotificationSettingsDomain"
        ),
        .target(
            name: "FeatureNotificationSettingsData",
            dependencies: [
                .target(
                    name: "FeatureNotificationSettingsDomain"
                ),
                .product(
                    name: "NetworkKit",
                    package: "Network"
                ),
                .product(
                    name: "NetworkError",
                    package: "NetworkErrors"
                )
            ],
            path: "Sources/NotificationSettings/NotificationSettingsData"
        ),
        .target(
            name: "FeatureNotificationSettingsUI",
            dependencies: [
                .target(name: "FeatureNotificationSettingsDomain"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "BlockchainComponentLibrary",
                    package: "BlockchainComponentLibrary"
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
                    name: "NetworkError",
                    package: "NetworkErrors"
                ),
                .product(
                    name: "ComposableArchitectureExtensions",
                    package: "ComposableArchitectureExtensions"
                )
            ],
            path: "Sources/NotificationSettings/NotificationSettingsUI"
        )
    ]
)
