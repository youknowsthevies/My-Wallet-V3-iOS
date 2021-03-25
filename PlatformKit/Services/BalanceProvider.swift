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

    /// Single wrapper for `fiatFundsBalances` the balances of the fiat based currencies
    var fiatFundsBalancesSingle: Single<MoneyBalancePairsCalculationStates> { get }
    
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
        let cryptoCalculationStates = [
            services[.crypto(.stellar)]!.calculationState,
            services[.crypto(.bitcoin)]!.calculationState,
            services[.crypto(.bitcoinCash)]!.calculationState,
            services[.crypto(.algorand)]!.calculationState,
        ]
        let erc20CalculationStates = [
            services[.crypto(.ethereum)]!.calculationState,
            services[.crypto(.pax)]!.calculationState,
            services[.crypto(.tether)]!.calculationState,
            services[.crypto(.wDGLD)]!.calculationState,
            services[.crypto(.yearnFinance)]!.calculationState
        ]
        let fiatCalculationStates = [
            services[.fiat(.GBP)]!.calculationState,
            services[.fiat(.EUR)]!.calculationState,
            services[.fiat(.USD)]!.calculationState
        ]
        let cryptoCalculationObservable = Observable.combineLatest(cryptoCalculationStates)
            .map { states in
                (
                    stellar: states[0],
                    bitcoin: states[1],
                    bitcoinCash: states[2],
                    algorand: states[3]
                )
            }
        let erc20Calculationbservable = Observable.combineLatest(erc20CalculationStates)
            .map { states in
                (
                    ethereum: states[0],
                    pax: states[1],
                    tether: states[2],
                    wdgld: states[3],
                    yearnFinance: states[4]
                )
            }
        let fiatCalculationObservable = Observable.combineLatest(fiatCalculationStates)
            .map { states in
                (
                    gbp: states[0],
                    eur: states[1],
                    usd: states[2]
                )
            }

        return Observable
            .combineLatest(cryptoCalculationObservable, erc20Calculationbservable, fiatCalculationObservable)
            .map { (crypto, erc20, fiat) in
                MoneyBalancePairsCalculationStates(
                    identifier: "total-balance",
                    statePerCurrency: [
                        .crypto(.ethereum): erc20.ethereum,
                        .crypto(.pax): erc20.pax,
                        .crypto(.stellar): crypto.stellar,
                        .crypto(.bitcoin): crypto.bitcoin,
                        .crypto(.bitcoinCash): crypto.bitcoinCash,
                        .crypto(.algorand): crypto.algorand,
                        .crypto(.tether): erc20.tether,
                        .crypto(.wDGLD): erc20.wdgld,
                        .crypto(.yearnFinance): erc20.yearnFinance,
                        .fiat(.GBP): fiat.gbp,
                        .fiat(.EUR): fiat.eur,
                        .fiat(.USD): fiat.usd
                    ]
                )
            }
            .share()
    }
    
    public var fiatFundsBalances: Observable<MoneyBalancePairsCalculationStates> {
        fiatBalances.map { $0.fiatBaseStates }
    }

    public var fiatFundsBalancesSingle: Single<MoneyBalancePairsCalculationStates> {
        fiatFundsBalances.take(1).asSingle()
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
