// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        )
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            path: "Modules/Analytics/Sources/AnalyticsKit"
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            path: "Modules/Analytics/Tests/AnalyticsKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
