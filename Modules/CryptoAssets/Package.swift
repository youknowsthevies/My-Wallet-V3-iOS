// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CryptoAssets",
    platforms: [.iOS(.v14)],
    products: [
        //        .library( // Unsure where AlgorandReceiveAddress comes from?
//            name: "AlgorandKit",
//            targets: ["AlgorandKit"]
//        ),
        .library(name: "BitcoinCashKit", targets: ["BitcoinCashKit"]),
        .library(name: "BitcoinChainKit", targets: ["BitcoinChainKit"]),
        .library(name: "BitcoinKit", targets: ["BitcoinKit"]),
        .library(name: "EthereumKit", targets: ["EthereumKit"]),
        .library(name: "ERC20Kit", targets: ["ERC20Kit"]),
        .library(name: "StellarKit", targets: ["StellarKit"]),

        .library(name: "BitcoinKitMock", targets: ["BitcoinKitMock"]),
        .library(name: "EthereumKitMock", targets: ["EthereumKitMock"]),
        .library(name: "ERC20KitMock", targets: ["ERC20KitMock"]),
        .library(name: "StellarKitMock", targets: ["StellarKitMock"])
    ],
    dependencies: [
        .package(name: "BigInt", url: "git@github.com:attaswift/BigInt.git", from: "5.2.1"),
        .package(name: "DIKit", url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(name: "RxSwift", url: "git@github.com:ReactiveX/RxSwift.git", from: "5.1.3"),
        .package(name: "stellarsdk", url: "git@github.com:oliveratkinson-bc/stellar-ios-mac-sdk.git", .branch("blockchain/swift-package-manager")),
        .package(path: "../Platform"),
        .package(path: "../FeatureTransaction"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "BitcoinCashKit",
            dependencies: [
                .target(name: "BitcoinChainKit")
            ]
        ),
        .target(
            name: "BitcoinChainKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "BitcoinKit",
            dependencies: [
                .target(name: "BitcoinChainKit")
            ]
        ),
        .target(
            name: "ERC20Kit",
            dependencies: [
                .target(name: "EthereumKit")
            ]
        ),
        .target(
            name: "EthereumKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "StellarKit",
            dependencies: [
                .product(name: "stellarsdk", package: "stellarsdk"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "FeatureTransactionDomain", package: "FeatureTransaction"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
//        .target(
//            name: "AlgorandKit",
//            dependencies: [
//                .product(name: "PlatformKit", package: "Platform"),
//                .product(name: "RxSwift", package: "RxSwift"),
//            ]
//        )
        .target(
            name: "BitcoinKitMock",
            dependencies: [
                .target(name: "BitcoinKit")
            ]
        ),
        .target(
            name: "ERC20KitMock",
            dependencies: [
                .target(name: "ERC20Kit")
            ]
        ),
        .target(
            name: "EthereumKitMock",
            dependencies: [
                .target(name: "EthereumKit")
            ]
        ),
        .target(
            name: "StellarKitMock",
            dependencies: [
                .target(name: "StellarKit")
            ]
        ),
        .testTarget(
            name: "BitcoinCashKitTests",
            dependencies: [
                .target(name: "BitcoinCashKit")
            ]
        ),
        .testTarget(
            name: "BitcoinChainKitTests",
            dependencies: [
                .target(name: "BitcoinChainKit")
            ]
        ),
        .testTarget(
            name: "BitcoinKitTests",
            dependencies: [
                .target(name: "BitcoinKit"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "ERC20KitTests",
            dependencies: [
                .target(name: "ERC20Kit")
            ]
        ),
        .testTarget(
            name: "EthereumKitTests",
            dependencies: [
                .target(name: "EthereumKit"),
                .target(name: "EthereumKitMock"),
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "StellarKitTests",
            dependencies: [
                .target(name: "StellarKit")
            ]
        )
    ]
)
