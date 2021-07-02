// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit

extension CryptoCurrency {
    static func mockERC20(name: String, precision: Int = 18, sortIndex: Int = 0) -> CryptoCurrency {
        .erc20(
            ERC20AssetModel(
                assetResponse: .init(
                    symbol: name,
                    name: name,
                    precision: precision,
                    products: [],
                    type: .init(
                        name: "ERC20",
                        minimumOnChainConfirmations: nil,
                        parentChain: "ETH",
                        erc20Address: "ETH",
                        logoPngUrl: "ETH",
                        websiteUrl: "ETH"
                    )
                ),
                sortIndex: sortIndex
            )!
        )
    }
}
