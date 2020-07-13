//
//  BalanceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift

/// Provider of balance services and total balance in `FiatValue`
public protocol BalanceProviding: class {
    
    subscript(currency: CryptoCurrency) -> AssetBalanceFetching { get }
    
    /// Streams the total fiat balance in the wallet
    var fiatBalance: Observable<FiatValueCalculationState> { get }
    
    /// Streams the fiat balances
    var fiatBalances: Observable<AssetFiatCryptoBalanceCalculationStates> { get }
    
    /// Triggers a refresh on the balances
    func refresh()
}

/// A cross-asset balance provider
public final class BalanceProvider: BalanceProviding {

    // MARK: - Balance
    
    /// Reduce cross asset fiat balance values into a single fiat value
    public var fiatBalance: Observable<FiatValueCalculationState> {
        fiatBalances
            .map { $0.totalFiat }
            .share()
    }
        
    /// Calculates all balances in `WalletBalance`
    public var fiatBalances: Observable<AssetFiatCryptoBalanceCalculationStates> {
        Observable
            .combineLatest(
                services[.ethereum]!.calculationState,
                services[.pax]!.calculationState,
                services[.stellar]!.calculationState,
                services[.bitcoin]!.calculationState,
                services[.bitcoinCash]!.calculationState,
                services[.algorand]!.calculationState,
                services[.tether]!.calculationState
            ) { (ethereum: $0, pax: $1, stellar: $2, bitcoin: $3, bitcoinCash: $4, algorand: $5, tether: $6) }
            .map { states in
                AssetFiatCryptoBalanceCalculationStates(
                    statePerCurrency: [
                        .ethereum: states.ethereum,
                        .pax: states.pax,
                        .stellar: states.stellar,
                        .bitcoin: states.bitcoin,
                        .bitcoinCash: states.bitcoinCash,
                        .algorand: states.algorand,
                        .tether: states.tether
                    ]
                )
            }
            .share()
    }
    
    public subscript(currency: CryptoCurrency) -> AssetBalanceFetching {
        services[currency]!
    }
    
    // MARK: - Services
    
    private var services: [CryptoCurrency: AssetBalanceFetching] = [:]
    
    // MARK: - Setup
    
    public init(algorand: AssetBalanceFetching,
                ether: AssetBalanceFetching,
                pax: AssetBalanceFetching,
                stellar: AssetBalanceFetching,
                bitcoin: AssetBalanceFetching,
                bitcoinCash: AssetBalanceFetching,
                tether: AssetBalanceFetching) {
        services[.algorand] = algorand
        services[.ethereum] = ether
        services[.pax] = pax
        services[.stellar] = stellar
        services[.bitcoin] = bitcoin
        services[.bitcoinCash] = bitcoinCash
        services[.tether] = tether
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }
}
