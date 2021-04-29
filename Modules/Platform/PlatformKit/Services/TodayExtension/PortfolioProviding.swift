// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol PortfolioProviding {
    var portfolio: Observable<Portfolio> { get }
}

public final class PortfolioProvider: PortfolioProviding {
    
    private let balanceProviding: BalanceProviding
    private let balanceChangeProviding: BalanceChangeProviding
    private let portfolioBalanceChangeProviding: PortfolioBalanceChangeProviding
    private let fiatCurrencyProviding: FiatCurrencyServiceAPI
    private let disposeBag = DisposeBag()
    
    public init(balanceProviding: BalanceProviding,
                balanceChangeProviding: BalanceChangeProviding,
                fiatCurrencyProviding: FiatCurrencyServiceAPI) {
        self.fiatCurrencyProviding = fiatCurrencyProviding
        self.balanceProviding = balanceProviding
        self.balanceChangeProviding = balanceChangeProviding
        self.portfolioBalanceChangeProviding = PortfolioBalanceChangeProvider(
            balanceProvider: balanceProviding,
            balanceChangeProvider: balanceChangeProviding
        )
    }
    
    // MARK: - PortfolioProviding
    
    public var portfolio: Observable<Portfolio> {
        let balancesObservable = Observable.combineLatest(
            balance(for: .ethereum),
            balance(for: .pax),
            balance(for: .stellar),
            balance(for: .bitcoin),
            balance(for: .bitcoinCash),
            balance(for: .tether)
        )
        return Observable.combineLatest(
            balancesObservable,
            change,
            fiatCurrencyProviding.fiatCurrencyObservable
            )
            .map { (values) -> Portfolio in
                let balances = values.0
                let change = values.1
                let fiatCurrency = values.2
                return .init(
                    ether: balances.0,
                    pax: balances.1,
                    stellar: balances.2,
                    bitcoin: balances.3,
                    bitcoinCash: balances.4,
                    tether: balances.5,
                    balanceChange: change,
                    fiatCurrency: fiatCurrency
                )
            }
    }
    
    // MARK: - PortfolioChange
    
    private var change: Observable<PortfolioBalanceChange> {
        portfolioBalanceChangeProviding
            .changeObservable
    }
    
    // MARK: - Balance Descriptions
    
    private func balance(for currency: CryptoCurrency) -> Observable<String> {
        balanceProviding[.crypto(currency)]
            .calculationState
            .compactMap { $0.value }
            .map { $0.total.base.amount }
            .catchErrorJustReturn(.zero)
            .map { $0.description }
    }
}
