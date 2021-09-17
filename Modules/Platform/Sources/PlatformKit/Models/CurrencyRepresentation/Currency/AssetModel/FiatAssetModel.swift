// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A fiat asset.
struct FiatAssetModel: AssetModel, Hashable {

    // MARK: - Internal Properties

    let code: String
    let displayCode: String
    let kind: AssetModelType = .fiat
    let name: String
    let precision: Int
    let products: [AssetModelProduct]
    let logoPngUrl: String? = nil
    let spotColor: String? = nil

    // MARK: - Setup

    /// Creates a fiat asset.
    ///
    /// - Parameter assetResponse: A supported fiat asset response.
    init(assetResponse: SupportedAssetsResponse.Asset) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.fiat.rawValue)
        code = assetResponse.symbol
        displayCode = assetResponse.displaySymbol ?? assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }

    static func == (lhs: FiatAssetModel, rhs: FiatAssetModel) -> Bool {
        lhs.code == rhs.code
            && lhs.kind == rhs.kind
    }
}
