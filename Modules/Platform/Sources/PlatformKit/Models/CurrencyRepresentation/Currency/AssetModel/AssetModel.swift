// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }

    public static func == (lhs: AssetModel, rhs: AssetModel) -> Bool {
        lhs.code == rhs.code && lhs.kind == rhs.kind
    }
}
