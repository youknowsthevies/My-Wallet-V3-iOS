// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "KeychainKit",
            targets: ["KeychainKit"]
        ),
        .library(
            name: "KeychainKitMock",
            targets: ["KeychainKitMock"]
        )
    ],
    dependencies: [
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "KeychainKit",
            dependencies: [
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "KeychainKitMock",
            dependencies: [
                .target(name: "KeychainKit")
            ]
        ),
        .testTarget(
            name: "KeychainKitTests",
            dependencies: [
                .target(name: "KeychainKit")
            ]
        )
    ]
)
