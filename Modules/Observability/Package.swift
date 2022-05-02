// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Observability",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Observability",
            targets: ["ObservabilityDomain"]
        ),
        .library(
            name: "ObservabilityDomain",
            targets: ["ObservabilityDomain"]
        )
    ],
    targets: [
        .target(
            name: "ObservabilityDomain"
        )
    ]
)
