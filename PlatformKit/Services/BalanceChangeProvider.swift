//
//  BalanceChangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BalanceChangeProviding: class {

    subscript(currency: CryptoCurrency) -> AssetBalanceChangeProviding { get }

    var change: Observable<AssetFiatCryptoBalanceCalculationStates> { get }
}

/// A service that providers a balance change in crypto fiat and percentages
public final class BalanceChangeProvider: BalanceChangeProviding {
    
    // MARK: - Services

    private let currencies: [CryptoCurrency]
    private let services: [CryptoCurrency: AssetBalanceChangeProviding]
    
    public var change: Observable<AssetFiatCryptoBalanceCalculationStates> {
        let currencies = self.currencies
        return Observable.combineLatest(currencies.compactMap { self[$0].calculationState })
            .map { Dictionary(uniqueKeysWithValues: zip(currencies, $0)) }
            .map { states -> AssetFiatCryptoBalanceCalculationStates in
                AssetFiatCryptoBalanceCalculationStates(statePerCurrency: states)
            }
    }
    
    // MARK: - Setup
    
    public init(
        currencies: [CryptoCurrency],
        ether: AssetBalanceChangeProviding,
        pax: AssetBalanceChangeProviding,
        stellar: AssetBalanceChangeProviding,
        bitcoin: AssetBalanceChangeProviding,
        bitcoinCash: AssetBalanceChangeProviding,
        algorand: AssetBalanceChangeProviding,
        tether: AssetBalanceChangeProviding) {
        self.currencies = currencies
        services = [
            .ethereum: ether,
            .pax: pax,
            .stellar: stellar,
            .bitcoin: bitcoin,
            .bitcoinCash: bitcoinCash,
            .algorand: algorand,
            .tether: tether
        ]
    }

    public subscript(currency: CryptoCurrency) -> AssetBalanceChangeProviding {
        services[currency]!
    }
}
