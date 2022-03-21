// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Tool",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "ToolKit",
            targets: ["ToolKit"]
        ),
        .library(
            name: "ToolKitMock",
            targets: ["ToolKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "combine-schedulers",
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.5.2"
        ),
        .package(
            name: "swift-case-paths",
            url: "https://github.com/pointfreeco/swift-case-paths",
            from: "0.7.0"
        ),
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(
            name: "swift-algorithms",
            url: "https://github.com/apple/swift-algorithms.git",
            from: "1.0.0"
        ),
        .package(
            name: "swift-collections",
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.0"
        ),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "ToolKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "BigInt", package: "BigInt")
            ]
        ),
        .target(
            name: "ToolKitMock",
            dependencies: [
                .target(name: "ToolKit")
            ]
        ),
        .testTarget(
            name: "ToolKitTests",
            dependencies: [
                .target(name: "ToolKit"),
                .target(name: "ToolKitMock"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
