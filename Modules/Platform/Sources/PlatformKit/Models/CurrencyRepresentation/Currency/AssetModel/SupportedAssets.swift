// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A list of supported assets.
struct SupportedAssets {

    // MARK: - Internal Properties

    /// The empty list of supported assets.
    static let empty = SupportedAssets(currencies: [])

    /// The list of supported assets.
    let currencies: [AssetModel]

    // MARK: - Setup

    /// Creates a list of supported assets.
    ///
    /// - Parameter response: A supported assets response.
    init(response: SupportedAssetsResponse) {
        currencies = response.currencies
            .enumerated()
            .compactMap { index, asset -> AssetModel? in
                switch asset.type.name {
                // TODO: IOS-5091: remove sortIndex, cryptocurrencies should not have an order,
                // but accounts should be sorted by balance.
                case SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue:
                    return CoinAssetModel(assetResponse: asset, sortIndex: 10 + index)
                case SupportedAssetsResponse.Asset.AssetType.Name.erc20.rawValue:
                    return ERC20AssetModel(assetResponse: asset, sortIndex: 1000 + index)
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

    /// Creates a list of supported assets.
    ///
    /// - Parameter currencies: A list of supported assets.
    private init(currencies: [AssetModel]) {
        self.currencies = currencies
    }
}
