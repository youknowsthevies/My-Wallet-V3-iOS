// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "FeatureActivity",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureActivity",
            targets: ["FeatureActivityDomain", "FeatureActivityUI", "FeatureActivityData"]
        ),
        .library(
            name: "FeatureActivityDomain",
            targets: ["FeatureActivityDomain"]
        ),
        .library(
            name: "FeatureActivityData",
            targets: ["FeatureActivityData"]
        ),
        .library(
            name: "FeatureActivityUI",
            targets: ["FeatureActivityUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "6.2.0"
        ),
        .package(
            url: "https://github.com/jackpooleybc/DIKit.git",
            branch: "safe-property-wrappers"
        ),
        .package(path: "../CryptoAssets"),
        .package(path: "../FeatureKYC"),
        .package(path: "../Network"),
        .package(path: "../Errors"),
        .package(path: "../Money"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../FeatureCardPayment")
    ],
    targets: [
        .target(
            name: "FeatureActivityDomain",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "PlatformKit", package: "Platform")
            ]
        ),
        .target(
            name: "FeatureActivityData",
            dependencies: [
                .target(name: "FeatureActivityDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Errors", package: "Errors"),
                .product(name: "MoneyKit", package: "Money"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "NetworkKit", package: "Network")
            ]
        ),
        .target(
            name: "FeatureActivityUI",
            dependencies: [
                .target(name: "FeatureActivityDomain"),
                .product(name: "BitcoinCashKit", package: "CryptoAssets"),
                .product(name: "BitcoinChainKit", package: "CryptoAssets"),
                .product(name: "BitcoinKit", package: "CryptoAssets"),
                .product(name: "ERC20Kit", package: "CryptoAssets"),
                .product(name: "EthereumKit", package: "CryptoAssets"),
                .product(name: "FeatureCardPaymentDomain", package: "FeatureCardPayment"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "StellarKit", package: "CryptoAssets")
            ]
        ),
        .testTarget(
            name: "FeatureActivityDomainTests",
            dependencies: [
                .target(name: "FeatureActivityDomain")
            ]
        ),
        .testTarget(
            name: "FeatureActivityUITests",
            dependencies: [
                .target(name: "FeatureActivityUI")
            ]
        )
    ]
)
