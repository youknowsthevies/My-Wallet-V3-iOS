// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift
import ToolKit

/// Provider of balance services and total balance in `FiatValue`
public protocol BalanceProviding: AnyObject {

    subscript(currency: CurrencyType) -> AssetBalanceFetching { get }

    /// Streams the total sum of the converted fiat balance of each
    var fiatBalance: Observable<FiatValueCalculationState> { get }

    /// Streams a `MoneyBalancePairsCalculationStates` containing the
    /// converted fiat balance of all services registered in this provider.
    var fiatBalances: Observable<MoneyBalancePairsCalculationStates> { get }

    /// Triggers a refresh on the balances
    func refresh()
}

/// A cross-asset balance provider
public final class BalanceProvider: BalanceProviding {

    // MARK: - Balance

    public var fiatBalance: Observable<FiatValueCalculationState> {
        fiatBalances
            .map { $0.totalFiat }
            .share()
    }

    public var fiatBalances: Observable<MoneyBalancePairsCalculationStates> {
        let observables = services
            .map { key, value -> Observable<[CurrencyType : MoneyBalancePairsCalculationState]> in
                value.calculationState.map { state in
                    [key: state]
                }
            }
        return Observable.combineLatest(observables)
            .map { data -> [CurrencyType : MoneyBalancePairsCalculationState] in
                // Reduce our `[Dictionary]` into a single `Dictionary`.
                data.reduce(into: [CurrencyType : MoneyBalancePairsCalculationState]()) { (result, element) in
                    result.merge(element)
                }
            }
            .map { statePerCurrency in
                MoneyBalancePairsCalculationStates(
                    identifier: "total-balance",
                    statePerCurrency: statePerCurrency
                )
            }
            .share(replay: 1, scope: .whileConnected)
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
