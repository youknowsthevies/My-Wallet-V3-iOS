// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Session",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "Session",
            targets: ["Session"]
        )
    ],
    targets: [
        .target(
            name: "Session"
        ),
        .testTarget(
            name: "SessionTests",
            dependencies: ["Session"]
        )
    ]
)
