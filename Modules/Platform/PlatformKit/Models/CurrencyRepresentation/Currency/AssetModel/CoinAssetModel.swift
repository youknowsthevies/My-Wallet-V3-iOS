// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A Level 1 coin AssetModel.
struct CoinAssetModel: AssetModel, Hashable {
    let code: String
    let kind: AssetModelType = .coin
    let name: String
    let precision: Int
    let products: [AssetModelProduct]

    init?(assetResponse: SupportedAssetsResponse.Asset) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue)
        code = assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }
}
