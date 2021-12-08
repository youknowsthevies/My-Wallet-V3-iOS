// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Metadata",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .library(
            name: "MetadataKit",
            targets: ["MetadataKit"]
        ),
        .library(
            name: "MetadataDataKit",
            targets: ["MetadataDataKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.1.2"
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "CryptoSwift",
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.4.2"
        ),
        .package(
            name: "MetadataHDWalletKit",
            url: "https://github.com/jackpooleybc/MetadataHDWalletKit",
            .revision("f96abeee64dec17dc5a90769ff1393965bd827b7")
        ),
        .package(path: "../Analytics"),
        .package(path: "../Network"),
        .package(path: "../NetworkErrors"),
        .package(path: "../Test"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "MetadataKit",
            dependencies: [
                .product(name: "MetadataHDWalletKit", package: "MetadataHDWalletKit"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "NetworkError", package: "NetworkErrors")
            ]
        ),
        .testTarget(
            name: "MetadataKitTests",
            dependencies: [
                "MetadataKit",
                "MetadataDataKit",
                .product(name: "MetadataHDWalletKit", package: "MetadataHDWalletKit"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkError", package: "NetworkErrors")
            ],
            resources: [
                .copy("Fixtures/Entries/Ethereum/ethereum_entry.json"),
                .copy("Fixtures/MetadataResponse/root_metadata_response.json")
            ]
        ),
        .target(
            name: "MetadataDataKit",
            dependencies: [
                "MetadataKit",
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "NetworkKit", package: "Network")
            ]
        )
    ]
)
