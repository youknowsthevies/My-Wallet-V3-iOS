// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

final class FiatCustodialAccount: FiatAccount {

    private(set) lazy var identifier: AnyHashable = "FiatCustodialAccount.\(fiatCurrency.code)"
    let actions: Single<AvailableActions> = .just([.deposit, .viewActivity])
    let isDefault: Bool = true
    let label: String
    let fiatCurrency: FiatCurrency

    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var canWithdrawFunds: Single<Bool> {
        /// TODO: Fetch transaction history and filer
        /// for transactions that are `withdrawals` and have a
        /// transactionState of `.pending`.
        /// If there are no items, the user can withdraw funds.
        unimplemented()
    }

    var pendingBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.pending)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    var balance: Single<MoneyValue> {
        balances
            .map(\.balance?.available)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var isFunded: Single<Bool> {
        balance.map(\.isPositive)
    }

    private let balanceService: TradingBalanceServiceAPI
    private let exchange: PairExchangeServiceAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: currencyType)
    }

    init(
        fiatCurrency: FiatCurrency,
        balanceService: TradingBalanceServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve()
    ) {
        label = fiatCurrency.defaultWalletName
        self.fiatCurrency = fiatCurrency
        self.balanceService = balanceService
        self.exchange = exchangeProviding[fiatCurrency]
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }

    func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        guard self.fiatCurrency != fiatCurrency else {
            return balance
                .map { balance in
                    MoneyValuePair(base: balance, quote: balance)
                }
        }
        return Single
            .zip(
                exchange.fiatPrice.take(1).asSingle(),
                balance
            )
            .map { exchangeRate, balance -> MoneyValuePair in
                try MoneyValuePair(base: balance, exchangeRate: exchangeRate.moneyValue)
            }
    }

    func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        balancePair(fiatCurrency: fiatCurrency)
    }
}
