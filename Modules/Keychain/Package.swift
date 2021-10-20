// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "KeychainKit",
            targets: ["KeychainKit"]
        )
    ],
    targets: [
        .target(
            name: "KeychainKit"
        ),
        .testTarget(
            name: "KeychainKitTests",
            dependencies: [
                .target(name: "KeychainKit")
            ]
        )
    ]
)
