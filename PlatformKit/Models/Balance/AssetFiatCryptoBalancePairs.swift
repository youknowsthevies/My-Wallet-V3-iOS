//
//  AssetFiatCryptoBalancePairs.swift
//  PlatformKit
//
//  Created by AlexM on 1/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// NOTE: `AssetFiatCryptoBalancePairs` is not a final name by any means.
/// `AssetFiatCryptoBalancePairs` is supposed to represent all the balances
/// for a given asset type. There are multiple `BalanceTypes`.
/// This allows for a total `FiatValue` and `CryptoValue` that represents
/// the users balance across all `BalanceTypes`.
public struct AssetFiatCryptoBalancePairs {
    
    public let currency: CryptoCurrency
    public let currencyCode: String
    
    public subscript(balanceType: BalanceType) -> FiatCryptoPair {
        fiatCryptoPairs[balanceType]!
    }
    
    // MARK: - Services
    
    private var fiatCryptoPairs: [BalanceType: FiatCryptoPair] = [:]
    
    // MARK: - Setup
    
    public init(wallet: FiatCryptoPair,
                trading: FiatCryptoPair,
                savings: FiatCryptoPair) {
        currencyCode = trading.fiat.currencyCode
        currency = trading.crypto.currencyType
        fiatCryptoPairs[.nonCustodial] = wallet
        fiatCryptoPairs[.custodial(.trading)] = trading
        fiatCryptoPairs[.custodial(.savings)] = savings
    }
}

public extension AssetFiatCryptoBalancePairs {
    /// The `FiatCryptoPair` representing the total `FiatValue` and `CryptoValue`
    /// across all `BalanceTypes`
    var total: FiatCryptoPair {
        .init(crypto: crypto, fiat: fiat)
    }
    
    /// The total `FiatValue` across all `BalanceTypes`
    var fiat: FiatValue {
        let total = fiatCryptoPairs.values.map { $0.fiat.amount }.reduce(0, +)
        return .create(amount: total, currencyCode: currencyCode)
    }
    
    /// The total `CryptoValue` across all `BalanceTypes`
    var crypto: CryptoValue {
        let total = fiatCryptoPairs.values.map { $0.crypto.amount }.reduce(0, +)
        return CryptoValue.createFromMinorValue(total, assetType: currency)
    }
    
    var isZero: Bool {
        fiat.isZero || crypto.isZero
    }
}
