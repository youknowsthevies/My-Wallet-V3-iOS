// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        ),
        .library(
            name: "AnalyticsKitMock",
            targets: ["AnalyticsKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "Mockingbird",
            url: "https://github.com/birdrides/mockingbird.git",
            .exact("0.18.1")
        )
    ],
    targets: [
        .target(
            name: "AnalyticsKit"
        ),
        .target(
            name: "AnalyticsKitMock",
            dependencies: [
                .target(name: "AnalyticsKit")
            ]
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            dependencies: [
                .target(name: "AnalyticsKit"),
                .product(name: "Mockingbird", package: "Mockingbird")
            ]
        )
    ]
)
