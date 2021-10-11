// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ComposableNavigation",
    platforms: [
        .iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ComposableNavigation",
            targets: ["ComposableNavigation"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.28.1"
        )
    ],
    targets: [
        .target(
            name: "ComposableNavigation",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "ComposableNavigationTests",
            dependencies: ["ComposableNavigation"]
        )
    ]
)
