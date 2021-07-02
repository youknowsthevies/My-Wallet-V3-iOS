// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An `AssetModel` describing a Fiat asset.
struct FiatAssetModel: AssetModel, Hashable {
    let name: String
    let code: String
    let precision: Int
    let kind: AssetModelType = .fiat
    let products: [AssetModelProduct]

    init?(assetResponse: SupportedAssetsResponse.Asset) {
        code = assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(code)
    }
}
