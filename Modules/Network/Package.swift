// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
            )
    ],
    dependencies: [
        .package(name: "Analytics", path: "../Analytics"),
        .package(name: "Tool", path: "../Tool"),
        .package(url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(url: "git@github.com:paulo-bc/RxCombine.git", from: "1.6.2"),
        .package(url: "git@github.com:ReactiveX/RxSwift.git", from: "5.1.3")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                "NetworkKit",
                .product(name: "RxSwift", package: "RxSwift")
            ]
        )
    ]
)
