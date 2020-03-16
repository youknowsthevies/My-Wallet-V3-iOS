//
//  CryptoCurrency+Extensions.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

extension CryptoCurrency {

    /// The legacy representation of `CryptoCurrency`
    var legacy: LegacyAssetType {
        switch self {
        case .bitcoin:
            return LegacyAssetType.bitcoin
        case .bitcoinCash:
            return LegacyAssetType.bitcoinCash
        case .ethereum:
            return LegacyAssetType.ether
        case .stellar:
            return LegacyAssetType.stellar
        case .pax:
            return LegacyAssetType.pax
        }
    }
    
    /// Returns `true` if an asset's addresses can be reused
    var shouldAddressesBeReused: Bool {
        return Set<CryptoCurrency>([.ethereum, .stellar, .pax]).contains(self)
    }
    
    /// Returns `true` for a bitcoin cash asset
    var isBitcoinCash: Bool {
        if case .bitcoinCash = self {
            return true
        } else {
            return false
        }
    }
    
    /// Returns `true` for any ERC20 asset
    var isERC20: Bool {
        switch self {
        case .pax:
            return true
        case .bitcoin, .bitcoinCash, .ethereum, .stellar:
            return false
        }
    }

    static let all: [CryptoCurrency] = {
        var allAssets: [CryptoCurrency] = [.bitcoin, .ethereum, .bitcoinCash]
        if AppFeatureConfigurator.shared.configuration(for: .stellar).isEnabled {
            allAssets.append(.stellar)
        }
        allAssets.append(.pax)
        return allAssets
    }()
    
    init(legacyAssetType: LegacyAssetType) {
        switch legacyAssetType {
        case .bitcoin:
            self = .bitcoin
        case .bitcoinCash:
            self = .bitcoinCash
        case .ether:
            self = .ethereum
        case .stellar:
            self = .stellar
        case .pax:
            self = .pax
        @unknown default:
            let message = "Trying to initialize with non-existing asset type: \(legacyAssetType)"
            CrashlyticsRecorder().error(message)
            fatalError(message)
        }
    }
}

extension CryptoCurrency {
    
    @available(*, deprecated, message: "Do not use this. Instead use `FiatValue` and `CryptoValue` to convert in combination with exchange service (`ExchangeProviding`)")
    func toFiat(
        amount: Decimal,
        from wallet: Wallet = WalletManager.shared.wallet
    ) -> String? {
        let input = amount as NSDecimalNumber
        
        switch self {
        case .bitcoin:
            let value = NumberFormatter.parseBitcoinValue(from: input.stringValue)
            return NumberFormatter.formatMoney(
                value.magnitude,
                localCurrency: true
            )
        case .ethereum:
            let value = NumberFormatter.formatEthToFiat(
                withSymbol: input.stringValue,
                exchangeRate: wallet.latestEthExchangeRate
            )
            return value
        case .bitcoinCash:
            let value = NumberFormatter.parseBitcoinValue(from: input.stringValue)
            return NumberFormatter.formatBch(
                withSymbol: value.magnitude,
                localCurrency: true
            )
        case .stellar:
            // TODO: add formatting methods
            return "stellar in fiat"
        case .pax:
            // TODO: add formatting methods
            fatalError("Not implemented yet")
        }
    }
    
    @available(*, deprecated, message: "Do not use this. Instead use `FiatValue` and `CryptoValue` to convert in combination with exchange service (`ExchangeProviding`)")
    func toCrypto(
        amount: Decimal,
        from wallet: Wallet = WalletManager.shared.wallet
    ) -> String? {
        let input = amount as NSDecimalNumber
        switch self {
        case .bitcoin:
            let value = NumberFormatter.parseBitcoinValue(from: input.stringValue)
            return NumberFormatter.formatMoney(value.magnitude)
        case .ethereum:
            guard let exchangeRate = wallet.latestEthExchangeRate else { return nil }
            return NumberFormatter.formatEth(
                withLocalSymbol: input.stringValue,
                exchangeRate: exchangeRate
            )
        case .bitcoinCash:
            let value = NumberFormatter.parseBitcoinValue(from: input.stringValue)
            return NumberFormatter.formatBch(withSymbol: value.magnitude)
        case .stellar:
            // TODO: add formatting methods
            return "stellar in crypto"
        case .pax:
            // TODO: add formatting methods
            fatalError("Not implemented yet")
        }
    }
}

