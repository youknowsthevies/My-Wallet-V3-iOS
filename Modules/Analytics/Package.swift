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
            name: "RxAnalyticsKit",
            targets: ["RxAnalyticsKit"]
        ),
        .library(
            name: "AnalyticsKitMock",
            targets: ["AnalyticsKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(
            name: "Mockingbird",
            url: "https://github.com/birdrides/mockingbird.git",
            from: "0.18.1"
        )
    ],
    targets: [
        .target(
            name: "AnalyticsKit"
        ),
        .target(
            name: "RxAnalyticsKit",
            dependencies: [
                .target(name: "AnalyticsKit"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
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
                .target(name: "RxAnalyticsKit"),
                .product(name: "Mockingbird", package: "Mockingbird")
            ]
        )
    ]
)
