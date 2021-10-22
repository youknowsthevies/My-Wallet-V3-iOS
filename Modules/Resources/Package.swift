// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Resources",
    products: [
        .library(name: "Resources", targets: ["Resources"])
    ],
    targets: [
        .target(name: "Resources")
    ]
)
