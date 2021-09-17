// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

/// A crypto currency, representing a digital asset.
public enum CryptoCurrency: Currency, Hashable, Codable, Comparable, CustomDebugStringConvertible, Equatable {

    /// A coin crypto currency.
    case coin(CoinAssetModel)

    /// An Ethereum ERC-20 crypto currency.
    case erc20(ERC20AssetModel)

    /// Creates a crypto currency.
    ///
    /// If `code` is invalid, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - code:                     A crypto currency code.
    ///   - enabledCurrenciesService: An enabled currencies service.
    public init?(code: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        guard let cryptoCurrency = enabledCurrenciesService.allEnabledCryptoCurrencies
            .first(where: { $0.code == code })
        else {
            return nil
        }

        self = cryptoCurrency
    }

    /// Creates an ERC-20 crypto currency.
    ///
    /// If `erc20Address` is invalid, this initializer returns `nil`.
    ///
    /// - Parameters:
    ///   - erc20Address:             An ERC-20 contract address.
    ///   - enabledCurrenciesService: An enabled currencies service.
    public init?(erc20Address: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        guard let cryptoCurrency = enabledCurrenciesService.allEnabledCryptoCurrencies.first(where: { currency in
            switch currency {
            case .coin:
                return false
            case .erc20(let erc20AssetModel):
                return erc20AssetModel.erc20Address.caseInsensitiveCompare(erc20Address) == .orderedSame
            }
        }) else {
            return nil
        }

        self = cryptoCurrency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let cryptoCurrency = CryptoCurrency(code: stringValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported currency \(stringValue)"
            )
        }
        self = cryptoCurrency
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }

    public var debugDescription: String {
        "CryptoCurrency.\(code)"
    }

    /// Whether the crypto currency is a coin asset.
    public var isCoin: Bool {
        switch self {
        case .coin:
            return true
        case .erc20:
            return false
        }
    }

    /// Whether the crypto currency is an Ethereum ERC-20 asset.
    public var isERC20: Bool {
        switch self {
        case .coin:
            return false
        case .erc20:
            return true
        }
    }

    /// A uniquely identifying tag.
    public var typeTag: AnyHashable {
        switch self {
        case .coin(let model):
            return model.typeTag
        case .erc20(let model):
            return model.typeTag
        }
    }

    /// The underlying asset of the crypto currency.
    public var assetModel: AssetModel {
        switch self {
        case .coin(let model):
            return model
        case .erc20(let model):
            return model
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .coin(let model):
            hasher.combine(model)
        case .erc20(let model):
            hasher.combine(model)
        }
    }
}

// MARK: - Currency

extension CryptoCurrency {

    public static let maxDisplayPrecision: Int = 8

    public var name: String {
        switch self {
        case .coin(let model):
            return model.name
        case .erc20(let model):
            return model.name
        }
    }

    public var code: String {
        switch self {
        case .coin(let model):
            return model.code
        case .erc20(let model):
            return model.code
        }
    }

    public var displayCode: String {
        switch self {
        case .coin(let model):
            return model.displayCode
        case .erc20(let model):
            return model.displayCode
        }
    }

    public var displaySymbol: String { displayCode }

    public var precision: Int {
        switch self {
        case .coin(let model):
            return model.precision
        case .erc20(let model):
            return model.precision
        }
    }

    public var displayPrecision: Int {
        min(8, precision)
    }

    /// A helper value for `Comparable` conformance.
    ///
    /// Coin assets are "smaller" than ERC-20 assets.
    private var integerValue: Int {
        switch self {
        case .coin(let model):
            return model.sortIndex
        case .erc20(let model):
            return 10000 + model.sortIndex
        }
    }

    public static func < (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        lhs.integerValue < rhs.integerValue
    }

    public static func == (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        switch (lhs, rhs) {
        case (.coin(let lhs), .coin(let rhs)):
            return lhs == rhs
        case (.erc20(let lhs), .erc20(let rhs)):
            return lhs == rhs
        case (.erc20, .coin), (.coin, .erc20):
            return false
        }
    }
}
