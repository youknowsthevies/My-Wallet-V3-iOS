// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        .library(
            name: "NetworkKitMock",
            targets: ["NetworkKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "Pulse",
            url: "https://github.com/kean/Pulse.git",
            from: "0.20.0"
        ),
        .package(name: "Analytics", path: "../Analytics"),
        .package(name: "Test", path: "../Test"),
        .package(name: "Tool", path: "../Tool"),
        .package(name: "NetworkErrors", path: "../NetworkErrors")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkError", package: "NetworkErrors"),
                .product(name: "PulseCore", package: "Pulse")
            ]
        ),
        .target(
            name: "NetworkKitMock",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
