// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

public final class InterestDepositOnChainTransactionEngine: OnChainTransactionEngine,
    InterestTransactionEngine
{
    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        unimplemented()
    }

    // MARK: - OnChainTransactionEngine

    public var askForRefreshConfirmation: (AskForRefreshConfirmation)!
    public var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    public var requireSecondPassword: Bool

    public var transactionTarget: TransactionTarget!
    public var sourceAccount: BlockchainAccount!

    // MARK: - Private Properties

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(for: self.sourceCryptoAccount.currencyType, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceCryptoAccount.currencyType), quote: $0) }
            }
    }

    private let priceService: PriceServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.accountLimitsRepository = accountLimitsRepository
    }

    public func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(transactionTarget is NonCustodialAccount)
        precondition(sourceAccount is InterestAccount)
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
        unimplemented()
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    public func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    public func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    public func execute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        unimplemented()
    }
}
