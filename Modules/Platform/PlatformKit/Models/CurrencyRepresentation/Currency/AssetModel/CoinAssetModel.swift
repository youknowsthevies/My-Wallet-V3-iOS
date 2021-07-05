// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A Level 1 coin AssetModel.
public struct CoinAssetModel: AssetModel, Hashable {
    public let code: String
    public let kind: AssetModelType = .coin
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public let minimumOnChainConfirmations: Int
    let sortIndex: Int

    public var typeTag: AnyHashable { "\(kind).\(code)" }

    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue)
        code = assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        minimumOnChainConfirmations = assetResponse.type.minimumOnChainConfirmations!
        self.sortIndex = sortIndex
    }

    init(code: String, name: String, precision: Int, products: [AssetModelProduct], minimumOnChainConfirmations: Int, sortIndex: Int) {
        self.code = code
        self.name = name
        self.precision = precision
        self.products = products
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
        CoinAssetModel(code: "ALGO", name: "Algorand", precision: 6, products: [], minimumOnChainConfirmations: 3, sortIndex: 1)
    }
    static var polkadot: CoinAssetModel {
        CoinAssetModel(code: "DOT", name: "Polkadot", precision: 10, products: [], minimumOnChainConfirmations: 3, sortIndex: 2)
    }
}
