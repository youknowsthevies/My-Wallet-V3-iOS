// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
    name: "OpenBanking",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(
            name: "OpenBanking",
            targets: ["OpenBanking"]
        )
    ],
    dependencies: [
        .package(
            name: "combine-schedulers",
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.5.0"
        ),
        .package(path: "../Network"),
        .package(path: "../Session"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
    ],
    targets: [
        .target(
            name: "OpenBanking",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "Session", package: "Session"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "OpenBankingTests",
            dependencies: [
                .target(name: "OpenBanking"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "TestKit", package: "Test")
            ],
            resources: [
                // swiftlint:disable line_length
                // $ cd Tests/OpenBankingTests
                // $ fd --glob *.json | xargs -L 1 bash -c 'printf ".copy(\"%s\"),\n" "$*" ' bash
                .copy("fixture/DELETE/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/DELETE_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/5adf0e04-ffc5-42ce-bc5b-3ce465016292/GET_nabu-gateway_payments_banktransfer_5adf0e04-ffc5-42ce-bc5b-3ce465016292.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/GET_nabu-gateway_payments_banktransfer.json"),
                .copy("fixture/GET/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/GET_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c.json"),
                .copy("fixture/GET/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a/GET_nabu-gateway_payments_payment_b039317d-df85-413f-932d-2719346a839a.json"),
                .copy("fixture/GET/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a/GET_nabu-gateway_payments_payment_b039317d-df85-413f-932d-2719346a839a_pending.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/POST_nabu-gateway_payments_banktransfer.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment/POST_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c_payment.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update/POST_nabu-gateway_payments_banktransfer_a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c_update.json"),
                .copy("fixture/POST/nabu-gateway/payments/banktransfer/one-time-token/POST_nabu-gateway_payments_banktransfer_one-time-token.json")
            ]
        )
    ]
)
