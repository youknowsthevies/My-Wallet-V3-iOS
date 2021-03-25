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
        let cryptoCalculationObservable = Observable
            .combineLatest(
                services[.crypto(.stellar)]!.calculationState,
                services[.crypto(.bitcoin)]!.calculationState,
                services[.crypto(.bitcoinCash)]!.calculationState,
                services[.crypto(.algorand)]!.calculationState
            )
            .map { (stellar, bitcoin, bitcoinCash, algorand) -> [CurrencyType : MoneyBalancePairsCalculationState] in
                [
                    .crypto(.stellar): stellar,
                    .crypto(.bitcoin): bitcoin,
                    .crypto(.bitcoinCash): bitcoinCash,
                    .crypto(.algorand): algorand
                ]
            }
        let erc20Calculationbservable = Observable
            .combineLatest(
                services[.crypto(.aave)]!.calculationState,
                services[.crypto(.ethereum)]!.calculationState,
                services[.crypto(.pax)]!.calculationState,
                services[.crypto(.tether)]!.calculationState,
                services[.crypto(.wDGLD)]!.calculationState,
                services[.crypto(.yearnFinance)]!.calculationState
            )
            .map { (aave, ethereum, pax, tether, wdgld, yearnFinance) -> [CurrencyType : MoneyBalancePairsCalculationState] in
                [
                    .crypto(.aave): aave,
                    .crypto(.ethereum): ethereum,
                    .crypto(.pax): pax,
                    .crypto(.tether): tether,
                    .crypto(.wDGLD): wdgld,
                    .crypto(.yearnFinance): yearnFinance
                ]
            }
        let fiatCalculationObservable = Observable
            .combineLatest(
                services[.fiat(.GBP)]!.calculationState,
                services[.fiat(.EUR)]!.calculationState,
                services[.fiat(.USD)]!.calculationState
            )
            .map { (gbp, eur, usd) -> [CurrencyType : MoneyBalancePairsCalculationState] in
                [
                    .fiat(.GBP): gbp,
                    .fiat(.EUR): eur,
                    .fiat(.USD): usd
                ]
            }

        return Observable
            .combineLatest(cryptoCalculationObservable, erc20Calculationbservable, fiatCalculationObservable)
            .map { (crypto, erc20, fiat) in
                MoneyBalancePairsCalculationStates(
                    identifier: "total-balance",
                    statePerCurrency: crypto.merge(with: erc20).merge(with: fiat)
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
