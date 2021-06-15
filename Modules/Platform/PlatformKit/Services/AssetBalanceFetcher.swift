// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxCocoa
import RxRelay
import RxSwift

public protocol AssetBalanceFetching {

    /// Non-Custodial balance service
    var wallet: SingleAccountBalanceFetching { get }

    /// Custodial balance service
    var trading: CustodialAccountBalanceFetching { get }

    /// Interest balance service
    var savings: CustodialAccountBalanceFetching { get }

    /// The calculation state of the asset balance
    /// [TICKET]: IOS-3884
    var calculationState: Observable<MoneyBalancePairsCalculationState> { get }

    /// Trigger a refresh on the balance and exchange rate
    func refresh()
}

public final class AssetBalanceFetcher: AssetBalanceFetching {

    // MARK: - Properties

    public let wallet: SingleAccountBalanceFetching
    public let trading: CustodialAccountBalanceFetching
    public let savings: CustodialAccountBalanceFetching

    /// The balance
    public var calculationState: Observable<MoneyBalancePairsCalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    private let calculationStateRelay = BehaviorRelay<MoneyBalancePairsCalculationState>(value: .calculating)
    private let exchange: PairExchangeServiceAPI
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                wallet.balanceMoneyObservable,
                trading.fundsState,
                savings.fundsState,
                exchange.fiatPrice
            )
            .map { payload in
                let (walletBalance, trading, savings, exchangeRate) = payload
                let fiatPrice = exchangeRate.moneyValue

                let baseCurrencyType = walletBalance.currencyType
                let quoteCurrencyType = fiatPrice.currencyType

                switch baseCurrencyType {
                case .fiat:
                    switch trading {
                    case .present(let tradingBalance):
                        return MoneyValueBalancePairs(
                            trading: try MoneyValuePair(base: tradingBalance.available, exchangeRate: fiatPrice)
                        )
                    case .absent:
                        return MoneyValueBalancePairs(baseCurrency: baseCurrencyType, quoteCurrency: quoteCurrencyType)
                    }
                case .crypto:
                    let tradingBalance = trading.balance?.available ?? .zero(currency: baseCurrencyType)
                    let savingBalance = savings.balance?.available ?? .zero(currency: baseCurrencyType)
                    return MoneyValueBalancePairs(
                        wallet: try MoneyValuePair(base: walletBalance, exchangeRate: fiatPrice),
                        trading: try MoneyValuePair(base: tradingBalance, exchangeRate: fiatPrice),
                        savings: try MoneyValuePair(base: savingBalance, exchangeRate: fiatPrice)
                    )
                }
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Setup

    public init(wallet: SingleAccountBalanceFetching,
                trading: CustodialAccountBalanceFetching,
                savings: CustodialAccountBalanceFetching,
                exchange: PairExchangeServiceAPI,
                blockchainAccountProvider: BlockchainAccountProviding = resolve()) {
        self.trading = trading
        self.wallet = wallet
        self.savings = savings
        self.exchange = exchange
    }

    public func refresh() {
        wallet.balanceFetchTriggerRelay.accept(())
        trading.balanceFetchTriggerRelay.accept(())
        savings.balanceFetchTriggerRelay.accept(())
        exchange.fetchTriggerRelay.accept(())
    }
}

/// A `AssetBalanceFetching` for withdrawable amounts.
public final class WithdrawableAssetBalanceFetcher: AssetBalanceFetching {

    // MARK: - Properties

    public let wallet: SingleAccountBalanceFetching
    public let trading: CustodialAccountBalanceFetching
    public let savings: CustodialAccountBalanceFetching

    /// The balance
    public var calculationState: Observable<MoneyBalancePairsCalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    private let calculationStateRelay = BehaviorRelay<MoneyBalancePairsCalculationState>(value: .calculating)
    private let exchange: PairExchangeServiceAPI
    private let disposeBag = DisposeBag()
    private let cryptoCurrency: CryptoCurrency

    private lazy var setup: Void = {
        let baseCurrencyType: CurrencyType = cryptoCurrency.currency
        Observable
            .combineLatest(
                trading.fundsState,
                savings.fundsState,
                exchange.fiatPrice
            )
            .map { payload in
                let (trading, savings, exchangeRate) = payload
                let fiatPrice = exchangeRate.moneyValue

                let quoteCurrencyType = fiatPrice.currencyType

                switch baseCurrencyType {
                case .fiat:
                    switch trading {
                    case .present(let tradingBalance):
                        return MoneyValueBalancePairs(
                            trading: try MoneyValuePair(base: tradingBalance.withdrawable, exchangeRate: fiatPrice)
                        )
                    case .absent:
                        return MoneyValueBalancePairs(baseCurrency: baseCurrencyType, quoteCurrency: quoteCurrencyType)
                    }
                case .crypto:
                    let tradingBalance = trading.balance?.withdrawable ?? .zero(currency: baseCurrencyType)
                    let savingBalance = savings.balance?.withdrawable ?? .zero(currency: baseCurrencyType)
                    return MoneyValueBalancePairs(
                        wallet: .zero(baseCurrency: baseCurrencyType, quoteCurrency: fiatPrice.currencyType),
                        trading: try MoneyValuePair(base: tradingBalance, exchangeRate: fiatPrice),
                        savings: try MoneyValuePair(base: savingBalance, exchangeRate: fiatPrice)
                    )
                }
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Setup

    public init(cryptoCurrency: CryptoCurrency,
                trading: CustodialAccountBalanceFetching,
                savings: CustodialAccountBalanceFetching,
                exchange: PairExchangeServiceAPI) {
        self.cryptoCurrency = cryptoCurrency
        // `wallet` doesn't support 'withdrawable'
        self.wallet = AbsentAccountBalanceFetching(currencyType: cryptoCurrency.currency, accountType: .nonCustodial)
        self.trading = trading
        self.savings = savings
        self.exchange = exchange
    }

    public func refresh() {
        trading.balanceFetchTriggerRelay.accept(())
        savings.balanceFetchTriggerRelay.accept(())
        exchange.fetchTriggerRelay.accept(())
    }
}
