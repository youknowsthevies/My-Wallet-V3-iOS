// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureApp",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureApp", targets: ["FeatureAppUI", "FeatureAppDomain"]),
        .library(name: "FeatureAppUI", targets: ["FeatureAppUI"]),
        .library(name: "FeatureAppDomain", targets: ["FeatureAppDomain"])
    ],
    dependencies: [
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
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
        .package(path: "../CryptoAssets"),
        .package(path: "../FeatureDashboard"),
        .package(path: "../FeatureDebug"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureOpenBanking"),
        .package(path: "../FeatureSettings"),
        .package(path: "../Localization"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../WalletPayload"),
        .package(path: "../RemoteNotifications"),
        .package(path: "../FeatureWithdrawalLocks"),
        .package(path: "../FeatureCardPayment"),
        .package(path: "../FeatureQRCodeScanner"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../BlockchainNamespace"),
        .package(path: "../FeatureActivity"),
        .package(path: "../UIComponents"),
        .package(path: "../Money"),
        .package(path: "../FeatureWalletConnect"),
        .package(path: "../BlockchainComponentLibrary"),
        .package(path: "../FeatureCardIssuing")
    ],
    targets: [
        .target(
            name: "FeatureAppUI",
            dependencies: [
                .target(name: "FeatureAppDomain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "BitcoinChainKit", package: "CryptoAssets"),
                .product(name: "ERC20Kit", package: "CryptoAssets"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "FeatureDebugUI", package: "FeatureDebug"),
                .product(name: "FeatureDashboardUI", package: "FeatureDashboard"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureOpenBankingDomain", package: "FeatureOpenBanking"),
                .product(name: "FeatureOpenBankingUI", package: "FeatureOpenBanking"),
                .product(name: "FeatureAuthenticationUI", package: "FeatureAuthentication"),
                .product(name: "FeatureSettingsDomain", package: "FeatureSettings"),
                .product(name: "RemoteNotificationsKit", package: "RemoteNotifications"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment"),
                .product(name: "FeatureQRCodeScannerDomain", package: "FeatureQRCodeScanner"),
                .product(name: "FeatureQRCodeScannerUI", package: "FeatureQRCodeScanner"),
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "BlockchainNamespace", package: "BlockchainNamespace"),
                .product(name: "FeatureActivityUI", package: "FeatureActivity"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "FeatureWalletConnectDomain", package: "FeatureWalletConnect"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "BlockchainComponentLibrary", package: "BlockchainComponentLibrary"),
                .product(name: "FeatureCardIssuingUI", package: "FeatureCardIssuing"),
                .product(name: "FeatureCardIssuingDomain", package: "FeatureCardIssuing")
            ]
        ),
        .target(
            name: "FeatureAppDomain",
            dependencies: [
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "WalletPayloadKit", package: "WalletPayload"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureWithdrawalLocksData", package: "FeatureWithdrawalLocks"),
                .product(name: "FeatureWithdrawalLocksDomain", package: "FeatureWithdrawalLocks"),
                .product(name: "FeatureSettingsDomain", package: "FeatureSettings")
            ]
        )
    ]
)
