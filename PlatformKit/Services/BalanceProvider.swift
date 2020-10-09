//
//  BalanceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

/// Provider of balance services and total balance in `FiatValue`
public protocol BalanceProviding: class {
    
    subscript(currency: CurrencyType) -> AssetBalanceFetching { get }
    
    /// Streams the total fiat balance in the wallet
    var fiatBalance: Observable<FiatValueCalculationState> { get }
    
    /// Streams the fiat balances
    var fiatBalances: Observable<MoneyBalancePairsCalculationStates> { get }
    
    /// Streams the balances of the fiat based currencies
    var fiatFundsBalances: Observable<MoneyBalancePairsCalculationStates> { get }
    
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
    public var fiatBalances: Observable<MoneyBalancePairsCalculationStates> {
        let calculationStates = [
            services[.crypto(.ethereum)]!.calculationState,
            services[.crypto(.pax)]!.calculationState,
            services[.crypto(.stellar)]!.calculationState,
            services[.crypto(.bitcoin)]!.calculationState,
            services[.crypto(.bitcoinCash)]!.calculationState,
            services[.crypto(.algorand)]!.calculationState,
            services[.crypto(.tether)]!.calculationState,
            services[.fiat(.GBP)]!.calculationState,
            services[.fiat(.EUR)]!.calculationState,
            services[.fiat(.USD)]!.calculationState
        ]
        return Observable
            .combineLatest(calculationStates)
            .map { (ethereum: $0[0], pax: $0[1], stellar: $0[2], bitcoin: $0[3], bitcoinCash: $0[4], algorand: $0[5], tether: $0[6], gbp: $0[7], eur: $0[8], usd: $0[9]) }
            .map { states in
                MoneyBalancePairsCalculationStates(
                    identifier: "total-balance",
                    statePerCurrency: [
                        .crypto(.ethereum): states.ethereum,
                        .crypto(.pax): states.pax,
                        .crypto(.stellar): states.stellar,
                        .crypto(.bitcoin): states.bitcoin,
                        .crypto(.bitcoinCash): states.bitcoinCash,
                        .crypto(.algorand): states.algorand,
                        .crypto(.tether): states.tether,
                        .fiat(.GBP): states.gbp,
                        .fiat(.EUR): states.eur,
                        .fiat(.USD): states.usd
                    ]
                )
            }
            .share()
    }
    
    public var fiatFundsBalances: Observable<MoneyBalancePairsCalculationStates> {
        fiatBalances.map { $0.fiatBaseStates }
    }

    public subscript(currency: Currency) -> AssetBalanceFetching {
        services[currency.currency]!
    }
    
    public subscript(currencyType: CurrencyType) -> AssetBalanceFetching {
        services[currencyType]!
    }
    
    // MARK: - Services
    
    private var services: [CurrencyType: AssetBalanceFetching] = [:]
    
    // MARK: - Setup
    
    public init(fiats: [FiatCurrency: AssetBalanceFetching],
                cryptos: [CryptoCurrency: AssetBalanceFetching]) {
        for (currency, service) in fiats {
            services[currency.currency] = service
        }
        for (currency, service) in cryptos {
            services[currency.currency] = service
        }
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }
}
