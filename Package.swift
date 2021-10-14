// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        ),
        .library(
            name: "SharedComponentLibrary",
            targets: ["SharedComponentLibrary"]
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
        ),
        .target(
            name: "SharedComponentLibrary",
            path: "Modules/ComponentLibrary/Sources/ComponentLibrary"
        ),
        .testTarget(
            name: "SharedComponentLibraryTests",
            path: "Modules/ComponentLibrary/Tests/ComponentLibraryTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
