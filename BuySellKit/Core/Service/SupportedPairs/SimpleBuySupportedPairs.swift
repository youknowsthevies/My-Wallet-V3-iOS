//
//  SimpleBuySupportedPairs.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Simple-Buy supported pairs
public struct SimpleBuySupportedPairs {
    static let empty: SimpleBuySupportedPairs = .init(pairs: [])
    
    /// A possible tradable pair supported by Simple-Buy feature
    public struct Pair {
        
        /// The crypto currency type
        public let cryptoCurrency: CryptoCurrency
        
        /// The fiat currency type
        public var fiatCurrency: FiatCurrency {
            minFiatValue.currency
        }
        
        /// The minimum fiat value to buy
        public let minFiatValue: FiatValue
        
        /// The maximum fiat value to buy
        public let maxFiatValue: FiatValue
    }
    
    /// Array of supported pairs
    public let pairs: [Pair]
    
    /// Returns all supported unique alphabetically sorted crypto-currencies,
    public var cryptoCurrencies: [CryptoCurrency] {
        return Array(cryptoCurrencySet).sorted { $0.name < $1.name }
    }
    
    var fiatCurrencySet: Set<FiatCurrency> {
        return Set(pairs.map { $0.minFiatValue.currency })
    }
    
    var cryptoCurrencySet: Set<CryptoCurrency> {
        return Set(pairs.map { $0.cryptoCurrency })
    }
    
    // MARK: - Methods
    
    /// Returns all pairs that include the given crypto-currency
    public func pairs(per cryptoCurrency: CryptoCurrency) -> [Pair] {
        return pairs.filter { $0.cryptoCurrency == cryptoCurrency }
    }
        
    func contains(fiatCurrency: FiatCurrency) -> Bool {
        return fiatCurrencySet.contains(fiatCurrency)
    }
    
    func contains(oneOf currencies: [FiatCurrency]) -> Bool {
        return !fiatCurrencySet.isDisjoint(with: currencies)
    }
    
    func contains(oneOf currencies: FiatCurrency...) -> Bool {
        return contains(oneOf: currencies)
    }
}

// MARK: - Setup

extension SimpleBuySupportedPairs {
    init(response: SimpleBuySupportedPairsResponse, filterOption: SupportedPairsFilterOption) {
        let pairs = response.pairs.compactMap { Pair(response: $0) }
        switch filterOption {
        case .all:
            self.pairs = pairs
        case .only(fiatCurrency: let currency):
            self.pairs = pairs.filter { $0.maxFiatValue.currency == currency }
        }
    }
}

extension SimpleBuySupportedPairs.Pair {
    init?(response: SimpleBuySupportedPairsResponse.Pair) {
        let components = response.pair.split(separator: "-")
        guard components.count == 2 else { return nil }
        let rawCryptoCurrency = String(components[0])
        
        guard let cryptoCurrency = CryptoCurrency(rawValue: rawCryptoCurrency) else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: String(components[1])) else {
            return nil
        }
        self.cryptoCurrency = cryptoCurrency
        
        minFiatValue = .init(minor: response.buyMin, currency: fiatCurrency)
        maxFiatValue = .init(minor: response.buyMax, currency: fiatCurrency)
    }
}
