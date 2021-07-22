// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An `AssetModel` describing an L2 Ethereum asset of the ERC20 type.
public struct ERC20AssetModel: AssetModel, Hashable {
    public static let typeTag: AnyHashable = AssetModelType.erc20

    public let code: String
    /// 0x prefixed contract address for ERC20 types, nil otherwise
    public let erc20Address: String
    public let kind: AssetModelType = .erc20
    public let logoPngUrl: String?
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public let spotColor: String?
    public var cryptoCurrency: CryptoCurrency { .erc20(self) }
    /// A `Hashable` tag that can be used to discern between different L1/L2 chains.
    public var typeTag: AnyHashable { AssetModelType.erc20 }

    let sortIndex: Int

    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        guard let erc20Address = assetResponse.type.erc20Address else {
            return nil
        }
        self.erc20Address = erc20Address
        logoPngUrl = assetResponse.type.logoPngUrl
        code = assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        spotColor = assetResponse.type.spotColor
        self.sortIndex = sortIndex
    }

    init(
        code: String,
        erc20Address: String,
        logoPngUrl: String?,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        spotColor: String?,
        sortIndex: Int
    ) {
        self.code = code
        self.erc20Address = erc20Address
        self.logoPngUrl = logoPngUrl
        self.name = name
        self.precision = precision
        self.products = products
        self.spotColor = spotColor
        self.sortIndex = sortIndex
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }
}

extension ERC20AssetModel {
    static let ogn = ERC20AssetModel(
        code: "OGN",
        erc20Address: "0x8207c1FfC5B6804F6024322CcF34F29c3541Ae26",
        logoPngUrl: nil,
        name: "Origin Token (OGN)",
        precision: 18,
        products: [.privateKey],
        spotColor: "1A82FF",
        sortIndex: 101
    )
    static let enj = ERC20AssetModel(
        code: "ENJ",
        erc20Address: "0xF629cBd94d3791C9250152BD8dfBDF380E2a3B9c",
        logoPngUrl: nil,
        name: "Enjin Coin",
        precision: 18,
        products: [.privateKey],
        spotColor: "624DBF",
        sortIndex: 102
    )
    static let comp = ERC20AssetModel(
        code: "COMP",
        erc20Address: "0xc00e94Cb662C3520282E6f5717214004A7f26888",
        logoPngUrl: nil,
        name: "Compound",
        precision: 18,
        products: [.privateKey],
        spotColor: "00D395",
        sortIndex: 103
    )
    static let link = ERC20AssetModel(
        code: "LINK",
        erc20Address: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
        logoPngUrl: nil,
        name: "Chainlink",
        precision: 18,
        products: [.privateKey],
        spotColor: "2A5ADA",
        sortIndex: 104
    )
    static let tbtc = ERC20AssetModel(
        code: "TBTC",
        erc20Address: "0x8dAEBADE922dF735c38C80C7eBD708Af50815fAa",
        logoPngUrl: nil,
        name: "tBTC",
        precision: 18,
        products: [.privateKey],
        spotColor: nil,
        sortIndex: 105
    )
    static let wbtc = ERC20AssetModel(
        code: "WBTC",
        erc20Address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        logoPngUrl: nil,
        name: "Wrapped Bitcoin",
        precision: 8,
        products: [.privateKey],
        spotColor: nil,
        sortIndex: 106
    )
    static let snx = ERC20AssetModel(
        code: "SNX",
        erc20Address: "0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F",
        logoPngUrl: nil,
        name: "Synthetix Network Token",
        precision: 18,
        products: [.privateKey],
        spotColor: nil,
        sortIndex: 107
    )
    static let sushi = ERC20AssetModel(
        code: "SUSHI",
        erc20Address: "0x6B3595068778DD592e39A122f4f5a5cF09C90fE2",
        logoPngUrl: nil,
        name: "Sushi",
        precision: 18,
        products: [.privateKey],
        spotColor: nil,
        sortIndex: 108
    )
    static let zrx = ERC20AssetModel(
        code: "ZRX",
        erc20Address: "0xE41d2489571d322189246DaFA5ebDe1F4699F498",
        logoPngUrl: nil,
        name: "ZRX",
        precision: 18,
        products: [.privateKey],
        spotColor: "000000",
        sortIndex: 109
    )
    static let usdc = ERC20AssetModel(
        code: "USDC",
        erc20Address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        logoPngUrl: nil,
        name: "USD Coin",
        precision: 6,
        products: [.privateKey],
        spotColor: "2775CA",
        sortIndex: 110
    )
    static let uni = ERC20AssetModel(
        code: "UNI",
        erc20Address: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
        logoPngUrl: nil,
        name: "Uniswap",
        precision: 18,
        products: [.privateKey],
        spotColor: "FF007A",
        sortIndex: 111
    )
    static let dai = ERC20AssetModel(
        code: "DAI",
        erc20Address: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        logoPngUrl: nil,
        name: "Multi-collateral DAI",
        precision: 18,
        products: [.privateKey],
        spotColor: "F5AC37",
        sortIndex: 112
    )
    static let bat = ERC20AssetModel(
        code: "BAT",
        erc20Address: "0x0D8775F648430679A709E98d2b0Cb6250d2887EF",
        logoPngUrl: nil,
        name: "Basic Attention Token",
        precision: 18,
        products: [.privateKey],
        spotColor: "FF4724",
        sortIndex: 113
    )
}
