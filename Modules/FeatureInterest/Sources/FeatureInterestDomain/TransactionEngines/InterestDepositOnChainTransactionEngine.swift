// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit

public final class InterestDepositOnChainTransactionEngine: InterestTransactionEngine {

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap { [sourceCryptoCurrency, accountLimitsRepository] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceCryptoCurrency,
                        fiatCurrency: fiatCurrency
                    )
                    .asObservable()
                    .take(1)
                    .asSingle()
            }
            .map(\.minDepositAmount)
    }

    // MARK: - OnChainTransactionEngine

    public var askForRefreshConfirmation: (AskForRefreshConfirmation)!

    public var requireSecondPassword: Bool

    public var transactionTarget: TransactionTarget!
    public var sourceAccount: BlockchainAccount!
    public let priceService: PriceServiceAPI
    public let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Private Properties

    private var minimumDepositCryptoLimits: Single<CryptoValue> {
        minimumDepositLimits
            .flatMap { [priceService, sourceAsset] fiatValue -> Single<(FiatValue, FiatValue)> in
                let quote = priceService
                    .price(of: sourceAsset, in: fiatValue.currency)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { $0.fiatValue ?? .zero(currency: fiatValue.currency) }
                return Single.zip(quote, .just(fiatValue))
            }
            .map { [sourceAsset] (quote: FiatValue, deposit: FiatValue) -> CryptoValue in
                deposit
                    .convertToCryptoValue(
                        exchangeRate: quote,
                        cryptoCurrency: sourceAsset.cryptoCurrency!
                    )
            }
    }

    private var sourceCryptoAccount: CryptoAccount {
        sourceAccount as! CryptoAccount
    }

    private let onChainEngine: OnChainTransactionEngine
    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        onChainEngine: OnChainTransactionEngine
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.accountLimitsRepository = accountLimitsRepository
        self.onChainEngine = onChainEngine
    }

    public func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmation
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
        onChainEngine.start(
            sourceAccount: sourceAccount,
            transactionTarget: transactionTarget,
            askForRefreshConfirmation: askForRefreshConfirmation
        )
    }

    public func assertInputsValid() {
        precondition(transactionTarget is CryptoReceiveAddress)
        precondition(sourceAccount is CryptoNonCustodialAccount)
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
        onChainEngine
            .initializeTransaction()
            .flatMap { [minimumDepositCryptoLimits] pendingTransaction in
                Single
                    .zip(
                        minimumDepositCryptoLimits
                            .map(\.moneyValue),
                        .just(pendingTransaction)
                    )
            }
            .map { minimum, pendingTransaction in
                var tx = pendingTransaction
                tx.limits = TransactionLimits(
                    minimum: minimum,
                    maximum: tx.maxLimit,
                    maximumDaily: tx.maxDailyLimit,
                    maximumAnnual: tx.maxAnnualLimit,
                    effectiveLimit: tx.limits?.effectiveLimit,
                    suggestedUpgrade: tx.limits?.suggestedUpgrade
                )
                tx.feeSelection = pendingTransaction
                    .feeSelection
                    .update(availableFeeLevels: [.regular])
                    .update(selectedLevel: .regular)
                return tx
            }
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let termsChecked = getTermsOptionValueFromPendingTransaction(pendingTransaction)
        let agreementChecked = getTransferAgreementOptionValueFromPendingTransaction(pendingTransaction)
        return onChainEngine
            .doBuildConfirmations(pendingTransaction: pendingTransaction)
            .map { [weak self] pendingTransaction in
                guard let self = self else {
                    unexpectedDeallocation()
                }
                return self.modifyEngineConfirmations(
                    pendingTransaction,
                    termsChecked: termsChecked,
                    agreementChecked: agreementChecked
                )
            }
    }

    public func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        onChainEngine
            .update(
                amount: amount,
                pendingTransaction: pendingTransaction
            )
    }

    public func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        onChainEngine
            .validateAmount(pendingTransaction: pendingTransaction)
            .map { pendingTransaction in
                let minimum = pendingTransaction.minLimit
                guard try pendingTransaction.amount >= minimum else {
                    return pendingTransaction.update(validationState: .belowMinimumLimit(minimum))
                }
                return pendingTransaction
            }
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        onChainEngine
            .doValidateAll(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) in
                guard pendingTransaction.agreementOptionValue, pendingTransaction.termsOptionValue else {
                    return .just(
                        pendingTransaction.update(validationState: .optionInvalid)
                    )
                }
                return self.validateAmount(
                    pendingTransaction: pendingTransaction
                )
            }
    }

    public func execute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        onChainEngine
            .execute(
                pendingTransaction: pendingTransaction,
                secondPassword: secondPassword
            )
    }

    public func doPostExecute(
        transactionResult: TransactionResult
    ) -> Completable {
        transactionTarget
            .onTxCompleted(transactionResult)
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.availableFeeLevels.contains(level))
        return .just(pendingTransaction)
    }
}
