//
//  PortfolioAccountBalanceFetching.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public struct PortfolioAccount {

    /// The users balance in CryptoValue
    let balance: MoneyValuePair
    
    /// The asset price in fiatValue
    let fiatValue: FiatValue
    
    /// The change in fiatValue
    let fiatChange: FiatValue
    
    /// Delta over time
    let changePercentage: Double
}

public extension PortfolioAccount {
    static func zero(currency: CryptoCurrency, fiatCurrencyCode: String) -> PortfolioAccount {
        .init(
            balance: .zero(baseCurrency: .crypto(currency), quoteCurrency: .crypto(currency)),
            fiatValue: .zero(currency: FiatCurrency(code: fiatCurrencyCode) ?? .USD),
            fiatChange: .zero(currency: FiatCurrency(code: fiatCurrencyCode) ?? .USD),
            changePercentage: 0.0
        )
    }
}


public final class PortfolioAccountBalanceFetching {
    
    // MARK: - Types
    
    public typealias CalculationState = ValueCalculationState<PortfolioAccount>
    
    // MARK: - Public Properties
    
    public var calculationState: Observable<CalculationState> {
        _ = setup
        return calculationStateRelay
            .asObservable()
    }
    
    // MARK: - Setup
    
    private lazy var setup: Void = {
        fiatCurrencyProviding
            .fiatCurrencyObservable
            .map { $0.code }
            .bind(to: currencyCodeRelay)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(Observable.just(account.cryptoValue),
                           exchangeAPI.fiatPrice,
                           fiatCurrencyProviding.fiatCurrencyObservable,
                           historicalPriceProvider.calculationState)
            .map { (cryptoValue, fiatValue, fiatCurrency, state) -> CalculationState in
                switch state {
                case .calculating,
                     .invalid:
                    return .calculating
                case .value(let response):
                    let delta = response.historicalPrices.delta
                    let currentPrice = response.currentFiatValue
                    let fiatChange = FiatValue.create(
                        major: response.historicalPrices.fiatChange,
                        currency: response.currentFiatValue.currencyType
                    )
                    let account = PortfolioAccount(
                        balance: .init(base: cryptoValue, quote: fiatValue),
                        fiatValue: currentPrice,
                        fiatChange: fiatChange,
                        changePercentage: delta
                    )
                    return .value(account)
                }
            }
            .catchErrorJustReturn(
                .value(
                    .zero(
                        currency: account.cryptoValue.currencyType,
                        fiatCurrencyCode: currencyCodeRelay.value
                    )
                )
            )
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Private Properties
    
    private let account: Portfolio.Account
    private let exchangeAPI: PairExchangeServiceAPI
    private let historicalPriceProvider: HistoricalFiatPriceServiceAPI
    private let fiatCurrencyProviding: FiatCurrencyServiceAPI
    private let calculationStateRelay = BehaviorRelay<CalculationState>(value: .calculating)
    private let currencyCodeRelay = BehaviorRelay<String>(value: "USD")
    private let disposeBag = DisposeBag()
    
    public init(account: Portfolio.Account,
                exchangeAPI: PairExchangeServiceAPI,
                historicalPriceProvider: HistoricalFiatPriceServiceAPI,
                fiatCurrencyProviding: FiatCurrencyServiceAPI) {
        self.account = account
        self.exchangeAPI = exchangeAPI
        self.historicalPriceProvider = historicalPriceProvider
        self.fiatCurrencyProviding = fiatCurrencyProviding
    }
    
}
