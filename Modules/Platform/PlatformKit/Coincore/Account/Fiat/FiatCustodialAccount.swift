// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

public class FiatCustodialAccount: FiatAccount {

    private typealias LocalizedString = LocalizationConstants.Account

    public let id: String
    public let actions: Single<AvailableActions> = .just([.deposit, .viewActivity])
    public let isDefault: Bool = true
    public let label: String
    public let fiatCurrency: FiatCurrency
    public let accountType: SingleAccountType = .custodial(.trading)

    public var canWithdrawFunds: Single<Bool> {
        /// TODO: Fetch transaction history and filer
        /// for transactions that are `withdrawals` and have a
        /// transactionState of `.pending`.
        /// If there are no items, the user can withdraw funds.
        unimplemented()
    }

    public var pendingBalance: Single<MoneyValue> {
        balanceProviding[currencyType]
            .trading
            .pendingBalanceMoney
    }

    public var isFunded: Single<Bool> {
        balanceProviding[currencyType]
            .trading
            .balanceMoney
            .map { $0.isPositive }
    }

    public var balance: Single<MoneyValue> {
        balanceProviding[currencyType]
            .trading
            .balanceMoney
    }

    private let balanceProviding: BalanceProviding
    private let exchange: PairExchangeServiceAPI

    init(fiatCurrency: FiatCurrency,
         exchangeProviding: ExchangeProviding = resolve(),
         balanceProviding: BalanceProviding = resolve()) {
        self.balanceProviding = balanceProviding
        self.exchange = exchangeProviding[fiatCurrency]
        self.fiatCurrency = fiatCurrency
        label = fiatCurrency.defaultWalletName
        id = "FiatCustodialAccount." + fiatCurrency.code
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }

    public func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
        guard self.fiatCurrency != fiatCurrency else {
            return balance
                .map { balance in
                    MoneyValuePair(base: balance, quote: balance)
                }
                .asObservable()
        }
        return exchange.fiatPrice
            .flatMap(weak: self) { (self, exchangeRate) in
                self.balance
                    .map { balance -> MoneyValuePair in
                        try MoneyValuePair(base: balance, exchangeRate: exchangeRate.moneyValue)
                    }
                    .asObservable()
            }
    }
}
