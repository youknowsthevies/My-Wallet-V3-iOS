// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

final class FiatCustodialAccount: FiatAccount {

    private(set) lazy var identifier: AnyHashable = "FiatCustodialAccount.\(fiatCurrency.code)"
    let isDefault: Bool = true
    let label: String
    let fiatCurrency: FiatCurrency

    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var actions: Single<AvailableActions> {
        let hasActionableBalance = actionableBalance
            .map(\.isPositive)
        let canTransactWithBanks = paymentMethodService
            .canTransactWithBankPaymentMethods(fiatCurrency: fiatCurrency)

        return Single.zip(canTransactWithBanks, hasActionableBalance)
            .map { (fiatSupported, hasPositiveBalance) in
                var availableActions: AvailableActions = [.viewActivity]
                if fiatSupported {
                    availableActions.insert(.deposit)
                    if hasPositiveBalance {
                        // TICKET: IOS-4988 - Implement canWithdrawFunds in FiatCustodialAccount
                        availableActions.insert(.withdraw)
                    }
                }
                return availableActions
            }
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
    private let paymentMethodService: PaymentMethodTypesServiceAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: currencyType)
    }

    init(
        fiatCurrency: FiatCurrency,
        balanceService: TradingBalanceServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        paymentMethodService: PaymentMethodTypesServiceAPI = resolve()
    ) {
        label = fiatCurrency.defaultWalletName
        self.fiatCurrency = fiatCurrency
        self.paymentMethodService = paymentMethodService
        self.balanceService = balanceService
        self.exchange = exchangeProviding[fiatCurrency]
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .buy,
             .send,
             .sell,
             .swap,
             .receive:
            return Single.just(false)
        case .deposit,
             .withdraw:
            // TODO: Account for OB
            let hasActionableBalance = actionableBalance
                .map(\.isPositive)
            let canTransactWithBanks = paymentMethodService
                .canTransactWithBankPaymentMethods(fiatCurrency: fiatCurrency)
            return Single.zip(canTransactWithBanks, hasActionableBalance)
                .map { canTransact, hasBalance in
                    if canTransact {
                        if action == .deposit {
                            return true
                        } else {
                            return hasBalance ? true : false
                        }
                    }
                    return false
                }
        }
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
