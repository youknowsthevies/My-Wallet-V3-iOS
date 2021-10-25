// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Localization",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(name: "Localization", targets: ["Localization"])
    ],
    targets: [
        .target(name: "Localization")
    ]
)
