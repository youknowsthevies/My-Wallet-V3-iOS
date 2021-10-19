// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An asset (crypto or fiat).
public protocol AssetModel {

    /// The asset code (e.g. `USD`, `BTC`, etc.).
    var code: String { get }

    /// The asset display code (e.g. `USD`, `BTC`, etc.).
    var displayCode: String { get }

    /// The asset type.
    var kind: AssetModelType { get }

    /// The asset name (e.g. `US Dollar`, `Bitcoin`, etc.).
    var name: String { get }

    /// The asset precision, representing the maximum number of fraction digits.
    var precision: Int { get }

    /// The list of supported asset products.
    var products: [AssetModelProduct] { get }

    /// The URL to the asset logo.
    var logoPngUrl: String? { get }

    /// The asset spot color.
    var spotColor: String? { get }
}

extension AssetModel {

    public func supports(product: AssetModelProduct) -> Bool {
        products.contains(product)
    }
}
