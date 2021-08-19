// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CommonCrypto",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "CommonCryptoKit", targets: ["CommonCryptoKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(
            name: "WalletCore",
            url: "git@github.com:oliveratkinson-bc/wallet-core.git",
            .revision("ef1483ce58db6c51dff8d06d5cd2de3804d65522")
        ),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "CommonCryptoKit",
            dependencies: [
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .testTarget(
            name: "CommonCryptoKitTests",
            dependencies: [
                "CommonCryptoKit",
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
