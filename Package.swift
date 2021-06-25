// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AnalyticsKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]),
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            path: "Modules/Analytics/AnalyticsKit"
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            path: "Modules/Analytics/AnalyticsKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
