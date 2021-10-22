// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RxTool",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "RxToolKit",
            targets: ["RxToolKit"]
        )
    ],
    dependencies: [
        .package(
            name: "RxSwift",
            url: "git@github.com:ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(
            name: "RxCombine",
            url: "git@github.com:paulo-bc/RxCombine.git",
            from: "1.6.2"
        ),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "RxToolKit",
            dependencies: [
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "RxToolKitTests",
            dependencies: [
                .target(name: "RxToolKit"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ]
        )
    ]
)
