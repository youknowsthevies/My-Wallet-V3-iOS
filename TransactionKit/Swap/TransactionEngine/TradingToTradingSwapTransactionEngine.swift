//
//  TradingToTradingSwapTransactionEngine.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingToTradingSwapTransactionEngine: SwapTransactionEngine {

    let fiatCurrencyService: FiatCurrencyServiceAPI
    let kycTiersService: KYCTiersServiceAPI
    let orderCreationService: OrderCreationServiceAPI
    let orderDirection: OrderDirection = .internal
    let orderQuoteService: OrderQuoteServiceAPI
    let priceService: PriceServiceAPI
    let quotesEngine: SwapQuotesEngine
    let requireSecondPassword: Bool = false
    let tradeLimitsService: TradeLimitsAPI
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: CryptoAccount!
    var transactionTarget: TransactionTarget!

    init(quotesEngine: SwapQuotesEngine,
         orderQuoteService: OrderQuoteServiceAPI = resolve(),
         orderCreationService: OrderCreationServiceAPI = resolve(),
         tradeLimitsService: TradeLimitsAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         kycTiersService: KYCTiersServiceAPI = resolve(),
         priceService: PriceServiceAPI = resolve()) {
        self.quotesEngine = quotesEngine
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
        self.tradeLimitsService = tradeLimitsService
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
        self.priceService = priceService
    }

    func assertInputsValid() {
        precondition(target is CryptoTradingAccount)
        precondition(sourceAccount is CryptoTradingAccount)
        precondition((target as! CryptoTradingAccount).asset != sourceAccount.asset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single
            .zip(
                quotesEngine.getRate(direction: orderDirection, pair: pair).take(1).asSingle(),
                self.fiatCurrencyService.fiatCurrency,
                self.sourceAccount.actionableBalance
            )
            .flatMap(weak: self) { (self, payload) -> Single<PendingTransaction> in
                let (pricedQuote, fiatCurrency, actionableBalance) = payload
                let pendingTransaction = PendingTransaction(
                    amount: .zero(currency: self.sourceAccount.asset),
                    available: actionableBalance,
                    fees: .zero(currency: self.sourceAccount.asset),
                    feeLevel: .none,
                    selectedFiatCurrency: fiatCurrency,
                    minimumLimit: nil,
                    maximumLimit: nil
                )
                return self.updateLimits(
                    pendingTransaction: pendingTransaction,
                    pricedQuote: pricedQuote,
                    fiatCurrency: fiatCurrency
                )
                .handleSwapPendingOrdersError(initialValue: pendingTransaction)
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        createOrder(pendingTransaction: pendingTransaction)
            .map { _ in
                TransactionResult.unHashed(amount: pendingTransaction.amount)
            }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(validateUpdateAmount(amount),
                   sourceAccount.actionableBalance)
            .map { (normalized: MoneyValue, balance: MoneyValue) -> PendingTransaction in
                pendingTransaction.update(amount: normalized, available: balance)
            }
            .do(onSuccess: { [weak self] transaction in
                self?.quotesEngine.updateAmount(transaction.amount.amount)
            })
            .map(weak: self) { (self, pendingTransaction) -> PendingTransaction in
                self.clearConfirmations(pendingTransaction: pendingTransaction)
            }
    }
}
