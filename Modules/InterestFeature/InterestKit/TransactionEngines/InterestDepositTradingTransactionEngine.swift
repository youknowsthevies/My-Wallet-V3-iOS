// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

public final class InterestDepositTradingTransationEngine: InterestTransactionEngine {

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        unimplemented()
    }

    // MARK: - TransactionEngine

    public var askForRefreshConfirmation: (AskForRefreshConfirmation)!
    public var sourceAccount: BlockchainAccount!
    public var transactionTarget: TransactionTarget!
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

    // MARK: - Private Properties

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(for: self.sourceAsset, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceAsset), quote: $0) }
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
        unimplemented()
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
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

    public func doPostExecute(
        transactionResult: TransactionResult
    ) -> Completable {
        unimplemented()
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        unimplemented()
    }
}
