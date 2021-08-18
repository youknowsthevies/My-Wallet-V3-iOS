// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "WalletPayload",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "WalletPayloadKit", targets: ["WalletPayloadKit"]),
        .library(name: "WalletPayloadKitMock", targets: ["WalletPayloadKitMock"])
    ],
    dependencies: [
        .package(url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(path: "../Localization"),
        .package(path: "../CommonCrypto"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "WalletPayloadKit",
            dependencies: [
                .product(name: "Localization", package: "Localization"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .target(
            name: "WalletPayloadKitMock",
            dependencies: ["WalletPayloadKit"]
        ),
        .testTarget(
            name: "WalletPayloadKitTests",
            dependencies: [
                "WalletPayloadKit",
                "WalletPayloadKitMock"
            ],
            resources: [
                .copy("Fixtures/wallet-data.json")
            ]
        )
    ]
)
