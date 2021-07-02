// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An `AssetModel` describing an L2 Ethereum asset of the ERC20 type.
public struct ERC20AssetModel: AssetModel, Hashable {
    public static let typeTag: AnyHashable = AssetModelType.erc20

    public let code: String
    /// 0x prefixed contract address for ERC20 types, nil otherwise
    public let erc20Address: String
    public let kind: AssetModelType = .erc20
    public let logoPngUrl: String
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public var cryptoCurrency: CryptoCurrency { .erc20(self) }
    /// A `Hashable` tag that can be used to discern between different L1/L2 chains.
    public var typeTag: AnyHashable { AssetModelType.erc20 }

    let sortIndex: Int

    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        guard let erc20Address = assetResponse.type.erc20Address else {
            return nil
        }
        guard let logoPngUrl = assetResponse.type.logoPngUrl else {
            return nil
        }
        self.erc20Address = erc20Address
        self.logoPngUrl = logoPngUrl
        code = assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        self.sortIndex = sortIndex
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }
}
