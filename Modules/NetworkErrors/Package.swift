// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NetworkErrors",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "NetworkErrors",
            targets: ["NetworkError", "NabuNetworkError"]
        ),
        .library(
            name: "NetworkError",
            targets: ["NetworkError"]
        ),
        .library(
            name: "NabuNetworkError",
            targets: ["NabuNetworkError"]
        ),
        .library(
            name: "NabuNetworkErrorMock",
            targets: ["NabuNetworkErrorMock"]
        )
    ],
    dependencies: [
        .package(path: "../Tool"),
        .package(path: "../Localization")
    ],
    targets: [
        .target(
            name: "NetworkError",
            dependencies: []
        ),
        .target(
            name: "NabuNetworkError",
            dependencies: [
                "NetworkError",
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Localization", package: "Localization")
            ]
        ),
        .target(
            name: "NabuNetworkErrorMock",
            dependencies: ["NabuNetworkError"]
        ),
        .testTarget(
            name: "NetworkErrorsTests",
            dependencies: [
                "NetworkError",
                "NabuNetworkError"
            ]
        )
    ]
)
