// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization

/// This is used to distinguish between different types of digital assets.
public enum CryptoCurrency: Currency, Hashable, Codable, Comparable, CustomDebugStringConvertible {

    case bitcoin
    case ethereum
    case bitcoinCash
    case stellar
    case algorand
    case polkadot
    case erc20(ERC20AssetModel)

    public init?(code: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        guard let cryptoCurrency = enabledCurrenciesService.allEnabledCryptoCurrencies
                .first(where: { $0.code == code }) else {
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
        switch (lhs, rhs) {
        case let (.erc20(lhsModel), .erc20(rhsModel)):
            return lhsModel.sortIndex < rhsModel.sortIndex
        default:
            return lhs.integerValue < rhs.integerValue
        }
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
        case .algorand:
            return 4
        case .polkadot:
            return 5
        case .erc20:
            return 6
        }
    }

    /// CryptoCurrency is supported in Receive.
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialReceiveSupport: Bool {
        switch self {
        case .algorand,
             .polkadot:
            return false
        case.bitcoin,
            .bitcoinCash,
            .ethereum,
            .stellar:
            return true
        case .erc20:
            return true
        }
    }

    /// CryptoCurrency is supported in Withdrawal (send crypto from custodial to non custodial account).
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialWithdrawalSupport: Bool {
        switch self {
        case .algorand,
             .polkadot:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .stellar:
            return true
        case .erc20:
            return true
        }
    }

    /// CryptoCurrency has non custodial support in the App.
    /// Used whenever we don't have access to the new Account architecture.
    public var hasNonCustodialSupport: Bool {
        switch self {
        case .algorand,
             .polkadot:
            return false
        case .bitcoin,
             .bitcoinCash,
             .ethereum,
             .stellar:
            return true
        case .erc20:
            return true
        }
    }

    /// CryptoCurrency has Non Custodial support in Swap.
    /// Used only if we don't have access to the new Account architecture.
    public var hasSwapSupport: Bool {
        hasNonCustodialSupport
    }

    public var name: String {
        switch self {
        case .algorand:
            return "Algorand"
        case .bitcoin:
            return "Bitcoin"
        case .bitcoinCash:
            return "Bitcoin Cash"
        case .ethereum:
            return "Ether"
        case .polkadot:
            return "Polkadot"
        case .stellar:
            return "Stellar"
        case let .erc20(model) where model.code == LegacyERC20Code.pax.rawValue:
            return "USD \(LocalizationConstants.digital)"
        case .erc20(let model):
            return model.name
        }
    }

    public var symbol: String { code }
    public var displaySymbol: String { displayCode }

    public var code: String {
        switch self {
        case .algorand:
            return "ALGO"
        case .bitcoin:
            return "BTC"
        case .bitcoinCash:
            return "BCH"
        case .erc20(let model):
            return model.code
        case .ethereum:
            return "ETH"
        case .polkadot:
            return "DOT"
        case .stellar:
            return "XLM"
        }
    }

    public var displayCode: String {
        switch self {
        case .algorand,
             .bitcoin,
             .bitcoinCash,
             .ethereum,
             .polkadot,
             .stellar:
            return code
        case let .erc20(model) where model.code == LegacyERC20Code.pax.rawValue:
            return "USD-D"
        case let .erc20(model) where model.code == LegacyERC20Code.wdgld.rawValue:
            return "wDGLD"
        case .erc20(let model):
            return model.code
        }
    }

    public var maxDecimalPlaces: Int {
        switch self {
        case .algorand:
            return 6
        case .stellar:
            return 7
        case .bitcoin,
             .bitcoinCash:
            return 8
        case .polkadot:
            return 10
        case .ethereum:
            return 18
        case .erc20(let model):
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
        case .algorand, .bitcoin, .bitcoinCash, .ethereum, .polkadot, .stellar:
            return false
        }
    }

    /// A `Hashable` tag that can be used to discern between different L1/L2 chains.
    public var typeTag: AnyHashable {
        switch self {
        case .erc20(let model):
            return model.typeTag
        case .algorand, .bitcoin, .bitcoinCash, .ethereum, .polkadot, .stellar:
            return self
        }
    }

    public var maxStartDate: TimeInterval {
        switch self {
        case .algorand:
            return 1560211225
        case .bitcoin:
            return 1282089600
        case .bitcoinCash:
            return 1500854400
        case .ethereum:
            return 1438992000
        case .polkadot:
            return 1615831200
        case .stellar:
            return 1525716000
        case let .erc20(model) where model.code == LegacyERC20Code.aave.rawValue:
            return 1615831200
        case let .erc20(model) where model.code == LegacyERC20Code.pax.rawValue:
            return 1555060318
        case let .erc20(model) where model.code == LegacyERC20Code.tether.rawValue:
            return 1511829681
        case let .erc20(model) where model.code == LegacyERC20Code.wdgld.rawValue:
            return 1605636000
        case let .erc20(model) where model.code == LegacyERC20Code.yearnFinance.rawValue:
            return 1615831200
        case .erc20:
            return CryptoCurrency.ethereum.maxStartDate
        }
    }
}
