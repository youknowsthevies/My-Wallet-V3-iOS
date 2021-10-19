// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A coin asset.
public struct CoinAssetModel: AssetModel, Hashable {

    // MARK: - Public Properties

    public let code: String
    public let displayCode: String
    public let kind: AssetModelType = .coin
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public let logoPngUrl: String?
    public let spotColor: String?

    /// The minimum number of on-chain confirmations.
    public let minimumOnChainConfirmations: Int

    /// The uniquely identifying tag.
    public var typeTag: AnyHashable { "\(kind).\(code)" }

    // MARK: - Internal Properties

    /// Temporary sorting index, while full dynamic asset migration is in progress.
    let sortIndex: Int

    // MARK: - Setup

    /// Creates a coin asset.
    ///
    /// - Parameters:
    ///   - assetResponse: A supported coin asset response.
    ///   - sortIndex:     A sorting index.
    init(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue)
        code = assetResponse.symbol
        displayCode = assetResponse.displaySymbol ?? assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        logoPngUrl = assetResponse.type.logoPngUrl
        spotColor = assetResponse.type.spotColor
        minimumOnChainConfirmations = assetResponse.type.minimumOnChainConfirmations!
        self.sortIndex = sortIndex
    }

    /// Creates a coin asset.
    ///
    /// - Parameters:
    ///   - code:                        A code.
    ///   - displayCode:                 A display code.
    ///   - name:                        A name.
    ///   - precision:                   A precision.
    ///   - producs:                     A list of supported products.
    ///   - logoPngUrl:                  A URL to a logo.
    ///   - spotColor:                   A spot color.
    ///   - minimumOnChainConfirmations: A minimum number of on-chain confirmations.
    ///   - sortIndex:                   A sorting index.
    init(
        code: String,
        displayCode: String,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        logoPngUrl: String?,
        spotColor: String?,
        minimumOnChainConfirmations: Int,
        sortIndex: Int
    ) {
        self.code = code
        self.displayCode = displayCode
        self.name = name
        self.precision = precision
        self.products = products
        self.logoPngUrl = logoPngUrl
        self.spotColor = spotColor
        self.minimumOnChainConfirmations = minimumOnChainConfirmations
        self.sortIndex = sortIndex
    }

    // MARK: - Internal Methods

    /// Creates a new coin asset by replacing the current list of supported asset products.
    ///
    /// - Parameter products: A list of supported asset products.
    func with(products: [AssetModelProduct]) -> CoinAssetModel {
        CoinAssetModel(
            code: code,
            displayCode: displayCode,
            name: name,
            precision: precision,
            products: products,
            logoPngUrl: logoPngUrl,
            spotColor: spotColor,
            minimumOnChainConfirmations: minimumOnChainConfirmations,
            sortIndex: sortIndex
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }

    public static func == (lhs: CoinAssetModel, rhs: CoinAssetModel) -> Bool {
        lhs.code == rhs.code
            && lhs.kind == rhs.kind
    }
}

extension CoinAssetModel {

    public static var bitcoin: CoinAssetModel {
        CoinAssetModel(
            code: "BTC",
            displayCode: "BTC",
            name: "Bitcoin",
            precision: 8,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "FF9B22",
            minimumOnChainConfirmations: 2,
            sortIndex: 1
        )
    }

    public static var bitcoinCash: CoinAssetModel {
        CoinAssetModel(
            code: "BCH",
            displayCode: "BCH",
            name: "Bitcoin Cash",
            precision: 8,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "8DC351",
            minimumOnChainConfirmations: 3,
            sortIndex: 3
        )
    }

    public static var ethereum: CoinAssetModel {
        CoinAssetModel(
            code: "ETH",
            displayCode: "ETH",
            name: "Ethereum",
            precision: 18,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "473BCB",
            minimumOnChainConfirmations: 30,
            sortIndex: 2
        )
    }

    public static var stellar: CoinAssetModel {
        CoinAssetModel(
            code: "XLM",
            displayCode: "XLM",
            name: "Stellar",
            precision: 7,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 4
        )
    }
}
