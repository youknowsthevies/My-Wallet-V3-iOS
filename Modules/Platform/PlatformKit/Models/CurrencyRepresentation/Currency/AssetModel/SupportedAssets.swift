// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A list of supported `AssetModel`.
struct SupportedAssets {
    static let empty = SupportedAssets(currencies: [])

    let currencies: [AssetModel]

    init(response: SupportedAssetsResponse) {
        currencies = response.currencies
            .enumerated()
            .compactMap { index, asset -> AssetModel? in
                switch asset.type.name {
                case SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue:
                    return CoinAssetModel(assetResponse: asset)
                case SupportedAssetsResponse.Asset.AssetType.Name.erc20.rawValue:
                    return ERC20AssetModel(assetResponse: asset, sortIndex: index)
                case SupportedAssetsResponse.Asset.AssetType.Name.fiat.rawValue:
                    return FiatAssetModel(assetResponse: asset)
                default:
                    #if INTERNAL_BUILD
                    fatalError("Unrecognized asset type \(asset.type.name)")
                    #else
                    return nil
                    #endif
                }
            }
    }

    private init(currencies: [AssetModel]) {
        self.currencies = currencies
    }
}
