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

    init(code: String,
         name: String,
         precision: Int,
         products: [AssetModelProduct],
         logoPngUrl: String?,
         spotColor: String?,
         minimumOnChainConfirmations: Int,
         sortIndex: Int) {
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
    static var algorand: CoinAssetModel {
        CoinAssetModel(
            code: "ALGO",
            name: "Algorand",
            precision: 6,
            products: [],
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 1
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
            sortIndex: 2
        )
    }
}
