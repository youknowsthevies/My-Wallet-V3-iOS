// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift
import ToolKit

/// A provider for balance change
public protocol AssetBalanceChangeProviding: AnyObject {

    /// A balance fetcher
    var balance: AssetBalanceFetching { get }

    /// A prices provider
    var prices: HistoricalFiatPriceServiceAPI { get }

    /// The measured change over a time period
    var calculationState: Observable<MoneyBalancePairsCalculationState> { get }
}

public final class AssetBalanceChangeProvider: AssetBalanceChangeProviding {

    // MARK: - AssetBalanceChangeProviding

    public let balance: AssetBalanceFetching
    public let prices: HistoricalFiatPriceServiceAPI

    public var calculationState: Observable<MoneyBalancePairsCalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let cryptoCurrency: CryptoCurrency
    private let calculationStateRelay = BehaviorRelay<MoneyBalancePairsCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        Observable
            .combineLatest(balance.calculationState, prices.calculationState)
            .map { (balance, prices) in
                guard let walletBalance = balance.value?[.nonCustodial] else { return .calculating }
                guard let tradingBalance = balance.value?[.custodial(.trading)] else { return .calculating }
                guard let savingsBalance = balance.value?[.custodial(.savings)] else { return .calculating }
                guard let historicalPriceValue = prices.value else { return .calculating }

                let delta = historicalPriceValue.historicalPrices.delta

                let previousWalletBalance = walletBalance.value(before: delta)
                let previousTradingBalance = tradingBalance.value(before: delta)
                let previousSavingsBalance = savingsBalance.value(before: delta)

                return .value(.init(
                        wallet: try walletBalance - previousWalletBalance,
                        trading: try tradingBalance - previousTradingBalance,
                        savings: try savingsBalance - previousSavingsBalance
                    )
                )
            }
            .catchErrorJustReturn(.calculating) // TODO: Error handling
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Setup

    public init(balance: AssetBalanceFetching,
                prices: HistoricalFiatPriceServiceAPI,
                cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
        self.balance = balance
        self.prices = prices
    }
}

extension AssetBalanceChangeProvider: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AssetBalanceChangeProvider for \(cryptoCurrency.code)"
    }
}
