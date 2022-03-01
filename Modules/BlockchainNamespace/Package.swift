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
        .package(url: "https://github.com/screensailor/Lexicon", .branch("trunk"))
    ],
    targets: [
        .executableTarget(
            name: "gen",
            dependencies: [
                .product(name: "Lexicon", package: "Lexicon"),
                .product(name: "SwiftLexicon", package: "Lexicon")
            ]
        ),
        .target(
            name: "BlockchainNamespace",
            dependencies: [
                .target(name: "AnyCoding"),
                .target(name: "FirebaseProtocol"),
                .product(name: "SwiftLexicon", package: "Lexicon")
            ],
            resources: [
                .copy("blockchain.json")
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
            dependencies: ["BlockchainNamespace"]
        ),
        .testTarget(
            name: "AnyCodingTests",
            dependencies: ["AnyCoding"]
        )
    ]
)
