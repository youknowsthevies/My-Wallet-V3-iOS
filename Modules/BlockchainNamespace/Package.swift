// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "BlockchainNamespace",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "BlockchainNamespace",
            targets: ["BlockchainNamespace"]
        ),
        .executable(
            name: "gen",
            targets: ["gen"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/screensailor/Lexicon", .revision("160c4c417f8490658a8396d0283fb0d6fb98c327"))
    ],
    targets: [
        .executableTarget(
            name: "gen",
            dependencies: [
                .product(name: "Lexicon", package: "Lexicon"),
                .product(name: "SwiftStandAlone", package: "Lexicon")
            ]
        ),
        .target(
            name: "BlockchainNamespace",
            dependencies: [
                .target(name: "AnyCoding"),
                .target(name: "FirebaseProtocol"),
                .product(name: "Lexicon", package: "Lexicon")
            ],
            resources: [
                .copy("blockchain.taskpaper")
            ]
        ),
        .target(
            name: "AnyCoding"
        ),
        .target(
            name: "FirebaseProtocol"
        ),
        .testTarget(
            name: "BlockchainNamespaceTests",
            dependencies: ["BlockchainNamespace"],
            resources: [
                .copy("test.taskpaper")
            ]
        ),
        .testTarget(
            name: "AnyCodingTests",
            dependencies: ["AnyCoding"]
        )
    ]
)
