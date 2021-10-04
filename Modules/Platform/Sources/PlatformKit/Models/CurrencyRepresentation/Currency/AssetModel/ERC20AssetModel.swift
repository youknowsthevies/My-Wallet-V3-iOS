// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A Ethereum ERC-20 asset.
public struct ERC20AssetModel: AssetModel, Hashable {

    // MARK: - Public Properties

    /// The ERC-20 contract address, prefixed by `0x`.
    public let erc20Address: String
    public let code: String
    public let displayCode: String
    public let kind: AssetModelType = .erc20
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public let logoPngUrl: String?
    public let spotColor: String?
    public var cryptoCurrency: CryptoCurrency { .erc20(self) }

    /// The uniquely identifying tag.
    public var typeTag: AnyHashable { AssetModelType.erc20 }

    // MARK: - Internal Properties

    /// Temporary sorting index, while full dynamic asset migration is in progress.
    let sortIndex: Int

    // MARK: - Setup

    /// Creates an Ethereum ERC-20 asset.
    ///
    /// If `assetResponse` does not have an ERC-20 address, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - assetResponse: A supported Ethereum ERC-20 asset response.
    ///   - sortIndex:     A sorting index.
    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.erc20.rawValue)
        guard let erc20Address = assetResponse.type.erc20Address else {
            return nil
        }
        self.erc20Address = erc20Address
        code = assetResponse.symbol
        displayCode = assetResponse.displaySymbol ?? assetResponse.symbol
        name = assetResponse.name
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        logoPngUrl = assetResponse.type.logoPngUrl
        spotColor = assetResponse.type.spotColor
        self.sortIndex = sortIndex
    }

    /// Creates an Ethereum ERC-20 asset.
    ///
    /// - Parameters:
    ///   - erc20Address: An ERC-20 contract address.
    ///   - code:         A code.
    ///   - displayCode:  A display code.
    ///   - name:         A name.
    ///   - precision:    A precision.
    ///   - producs:      A list of supported products.
    ///   - logoPngUrl:   A URL to a logo.
    ///   - spotColor:    A spot color.
    ///   - sortIndex:    A sorting index.
    init(
        erc20Address: String,
        code: String,
        displayCode: String,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        logoPngUrl: String?,
        spotColor: String?,
        sortIndex: Int
    ) {
        self.erc20Address = erc20Address
        self.code = code
        self.displayCode = displayCode
        self.name = name
        self.precision = precision
        self.products = products
        self.logoPngUrl = logoPngUrl
        self.spotColor = spotColor
        self.sortIndex = sortIndex
    }

    // MARK: - Internal Methods

    /// Creates a new Ethereum ERC-20 asset by replacing the current list of supported asset products.
    ///
    /// - Parameter products: A list of supported asset products.
    func with(products: [AssetModelProduct]) -> ERC20AssetModel {
        ERC20AssetModel(
            erc20Address: erc20Address,
            code: code,
            displayCode: displayCode,
            name: name,
            precision: precision,
            products: products,
            logoPngUrl: logoPngUrl,
            spotColor: spotColor,
            sortIndex: sortIndex
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }

    public static func == (lhs: ERC20AssetModel, rhs: ERC20AssetModel) -> Bool {
        lhs.code == rhs.code
            && lhs.kind == rhs.kind
    }
}
