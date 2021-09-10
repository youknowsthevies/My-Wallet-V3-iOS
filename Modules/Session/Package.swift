// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Session",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(name: "Session", targets: ["Session"])
    ],
    dependencies: [

    ],
    targets: [
        .target(name: "Session", dependencies: []),
        .testTarget(name: "SessionTests", dependencies: ["Session"])
    ]
)
