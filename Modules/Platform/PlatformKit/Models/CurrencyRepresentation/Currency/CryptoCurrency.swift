// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import ToolKit

/// This is used to distinguish between different types of digital assets.
public enum CryptoCurrency: Currency, Hashable, Codable, Comparable, CustomDebugStringConvertible {

    case bitcoin
    case ethereum
    case bitcoinCash
    case stellar
    case other(CoinAssetModel)
    case erc20(ERC20AssetModel)

    public init?(code: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        guard let cryptoCurrency = enabledCurrenciesService.allEnabledCryptoCurrencies
            .first(where: { $0.code == code })
        else {
            return nil
        }
        self = cryptoCurrency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let cryptoCurrency = CryptoCurrency(code: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported currency \(stringValue)")
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
}

// MARK: - Currency

extension CryptoCurrency {

    public static let maxDisplayableDecimalPlaces: Int = 8

    /// Sort currencies, first non ERC20 coins following `integerValue` value, then ERC20 coins sorted as we received them.
    public static func < (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        lhs.integerValue < rhs.integerValue
    }

    /// Helper value for `Comparable` conformance.
    private var integerValue: Int {
        switch self {
        case .bitcoin:
            return 0
        case .ethereum:
            return 1
        case .bitcoinCash:
            return 2
        case .stellar:
            return 3
        case .other(let model):
            return 100000 + model.sortIndex
        case .erc20(let model):
            return 200000 + model.sortIndex
        }
    }

    /// CryptoCurrency is supported in Withdrawal (send crypto from custodial to non custodial account).
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialWithdrawalSupport: Bool {
        switch self {
        case .other:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .stellar,
             .erc20:
            return true
        }
    }

    public var name: String {
        switch self {
        case .bitcoin:
            return "Bitcoin"
        case .bitcoinCash:
            return "Bitcoin Cash"
        case .ethereum:
            return "Ether"
        case .stellar:
            return "Stellar"
        case .erc20(let model) where model.code == LegacyERC20Code.pax.rawValue:
            return "USD \(LocalizationConstants.digital)"
        case .erc20(let model):
            return model.name
        case .other(let model):
            return model.name
        }
    }

    public var symbol: String { code }
    public var displaySymbol: String { displayCode }

    public var code: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .bitcoinCash:
            return "BCH"
        case .erc20(let model):
            return model.code
        case .other(let model):
            return model.code
        case .ethereum:
            return "ETH"
        case .stellar:
            return "XLM"
        }
    }

    public var displayCode: String {
        switch self {
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .stellar:
            return code
        case .other(let model):
            return model.code
        case .erc20(let model) where model.code == LegacyERC20Code.pax.rawValue:
            return "USD-D"
        case .erc20(let model) where model.code == LegacyERC20Code.wdgld.rawValue:
            return "wDGLD"
        case .erc20(let model):
            return model.code
        }
    }

    public var maxDecimalPlaces: Int {
        switch self {
        case .stellar:
            return 7
        case .bitcoin,
             .bitcoinCash:
            return 8
        case .ethereum:
            return 18
        case .erc20(let model):
            return model.precision
        case .other(let model):
            return model.precision
        }
    }

    public var maxDisplayableDecimalPlaces: Int {
        min(8, maxDecimalPlaces)
    }

    /// Returns `true` for any ERC20 asset
    public var isERC20: Bool {
        switch self {
        case .erc20:
            return true
        case .bitcoin, .bitcoinCash, .ethereum, .stellar, .other:
            return false
        }
    }

    /// Returns `true` for any ERC20 asset
    public var isOther: Bool {
        switch self {
        case .other:
            return true
        case .bitcoin, .bitcoinCash, .ethereum, .stellar, .erc20:
            return false
        }
    }

    /// A `Hashable` tag that can be used to discern between different L1/L2 chains.
    public var typeTag: AnyHashable {
        switch self {
        case .erc20(let model):
            return model.typeTag
        case .other(let model):
            return model.typeTag
        case .bitcoin, .bitcoinCash, .ethereum, .stellar:
            return self
        }
    }

    public var maxStartDate: TimeInterval {
        switch self {
        case .bitcoin:
            return 1282089600
        case .bitcoinCash:
            return 1500854400
        case .ethereum:
            return 1438992000
        case .stellar:
            return 1525716000
        case .erc20(let model):
            switch model.code {
            case LegacyERC20Code.aave.rawValue:
                return 1615831200
            case LegacyERC20Code.pax.rawValue:
                return 1555060318
            case LegacyERC20Code.tether.rawValue:
                return 1511829681
            case LegacyERC20Code.wdgld.rawValue:
                return 1605636000
            case LegacyERC20Code.yearnFinance.rawValue:
                return 1615831200
            default:
                // TODO: IOS-4958: Use correct date from model.
                return CryptoCurrency.ethereum.maxStartDate
            }
        case .other(let model):
            switch model.code {
            case LegacyCustodialCode.polkadot.rawValue:
                return 1615831200
            case LegacyCustodialCode.algorand.rawValue:
                return 1560211225
            default:
                // TODO: IOS-4958: Use correct date from model.
                return 1625097600
            }
        }
    }
}
