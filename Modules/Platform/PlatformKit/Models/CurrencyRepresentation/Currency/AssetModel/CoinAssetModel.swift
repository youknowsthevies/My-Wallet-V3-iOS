// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A Level 1 coin AssetModel.
public struct CoinAssetModel: AssetModel, Hashable {
    public let code: String
    public let kind: AssetModelType = .coin
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public let logoPngUrl: String?
    public let spotColor: String?
    public let minimumOnChainConfirmations: Int
    let sortIndex: Int

    public var typeTag: AnyHashable { "\(kind).\(code)" }

    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue)
        code = assetResponse.symbol
        name = assetResponse.name
        logoPngUrl = assetResponse.type.logoPngUrl
        spotColor = assetResponse.type.spotColor
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        minimumOnChainConfirmations = assetResponse.type.minimumOnChainConfirmations!
        self.sortIndex = sortIndex
    }

    init(
        code: String,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        logoPngUrl: String?,
        spotColor: String?,
        minimumOnChainConfirmations: Int,
        sortIndex: Int
    ) {
        self.code = code
        self.name = name
        self.precision = precision
        self.products = products
        self.logoPngUrl = logoPngUrl
        self.spotColor = spotColor
        self.minimumOnChainConfirmations = minimumOnChainConfirmations
        self.sortIndex = sortIndex
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }
}

extension CoinAssetModel {

    public static var bitcoin: CoinAssetModel {
        CoinAssetModel(
            code: "BTC",
            name: "Bitcoin",
            precision: 8,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "FF9B22",
            minimumOnChainConfirmations: 2,
            sortIndex: 1
        )
    }

    public static var bitcoinCash: CoinAssetModel {
        CoinAssetModel(
            code: "BCH",
            name: "Bitcoin Cash",
            precision: 8,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "8DC351",
            minimumOnChainConfirmations: 3,
            sortIndex: 3
        )
    }

    public static var ethereum: CoinAssetModel {
        CoinAssetModel(
            code: "ETH",
            name: "Ethereum",
            precision: 18,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "473BCB",
            minimumOnChainConfirmations: 30,
            sortIndex: 2
        )
    }

    public static var stellar: CoinAssetModel {
        CoinAssetModel(
            code: "XLM",
            name: "Stellar",
            precision: 7,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 4
        )
    }

    static var algorand: CoinAssetModel {
        CoinAssetModel(
            code: "ALGO",
            name: "Algorand",
            precision: 6,
            products: [],
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 101
        )
    }

    static var polkadot: CoinAssetModel {
        CoinAssetModel(
            code: "DOT",
            name: "Polkadot",
            precision: 10,
            products: [],
            logoPngUrl: nil,
            spotColor: "E6007A",
            minimumOnChainConfirmations: 3,
            sortIndex: 102
        )
    }

    static var dogecoin: CoinAssetModel {
        CoinAssetModel(
            code: "DOGE",
            name: "Dogecoin",
            precision: 8,
            products: [],
            logoPngUrl: nil,
            spotColor: "C2A633",
            minimumOnChainConfirmations: 3,
            sortIndex: 103
        )
    }

    static var bitClout: CoinAssetModel {
        CoinAssetModel(
            code: "CLOUT",
            name: "BitClout",
            precision: 9,
            products: [],
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 104
        )
    }

    static var ethereumClassic: CoinAssetModel {
        CoinAssetModel(
            code: "ETC",
            name: "Ethereum Classic",
            precision: 18,
            products: [],
            logoPngUrl: nil,
            spotColor: "33FF99",
            minimumOnChainConfirmations: 3,
            sortIndex: 105
        )
    }

    static var litecoin: CoinAssetModel {
        CoinAssetModel(
            code: "LTC",
            name: "Litecoin",
            precision: 18,
            products: [],
            logoPngUrl: nil,
            spotColor: "BFBBBB",
            minimumOnChainConfirmations: 3,
            sortIndex: 106
        )
    }

    static var blockstack: CoinAssetModel {
        CoinAssetModel(
            code: "STX",
            name: "Stacks",
            precision: 6,
            products: [],
            logoPngUrl: nil,
            spotColor: "211F6D",
            minimumOnChainConfirmations: 3,
            sortIndex: 107
        )
    }

    static var tezos: CoinAssetModel {
        CoinAssetModel(
            code: "XTZ",
            name: "Tezos",
            precision: 6,
            products: [],
            logoPngUrl: nil,
            spotColor: "2C7DF7",
            minimumOnChainConfirmations: 3,
            sortIndex: 108
        )
    }

    static var mobileCoin: CoinAssetModel {
        CoinAssetModel(
            code: "MOB",
            name: "Mobile Coin",
            precision: 12,
            products: [],
            logoPngUrl: nil,
            spotColor: "243855",
            minimumOnChainConfirmations: 3,
            sortIndex: 109
        )
    }

    static var theta: CoinAssetModel {
        CoinAssetModel(
            code: "THETA",
            name: "Theta Network",
            precision: 18,
            products: [],
            logoPngUrl: nil,
            spotColor: "2AB8E6",
            minimumOnChainConfirmations: 3,
            sortIndex: 110
        )
    }

    static var near: CoinAssetModel {
        CoinAssetModel(
            code: "NEAR",
            name: "NEAR Protocol",
            precision: 24,
            products: [],
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 111
        )
    }

    static var eos: CoinAssetModel {
        CoinAssetModel(
            code: "EOS",
            name: "EOS",
            precision: 4,
            products: [],
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 112
        )
    }
}
