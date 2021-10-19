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
            .flatMap { [minimumDepositLimits] pendingTransaction in
                Single
                    .zip(
                        minimumDepositLimits,
                        .just(pendingTransaction)
                    )
            }
            .map { minimum, pendingTransaction in
                var tx = pendingTransaction
                tx.minimumLimit = minimum.moneyValue
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
            .flatMapCompletable(weak: self) { (self, pendingTransaction) in
                self.checkIfAmountIsBelowMinimumLimit(pendingTransaction)
            }
            .andThen(.just(pendingTransaction))
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        onChainEngine
            .doValidateAll(pendingTransaction: pendingTransaction)
            .flatMapCompletable(weak: self) { (self, pendingTransaction) in
                self.checkIfCanExecute(pendingTransaction)
            }
            .andThen(.just(pendingTransaction))
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

    // MARK: - Private Functions

    private func checkIfCanExecute(
        _ pendingTransaction: PendingTransaction
    ) -> Completable {
        Completable.fromCallable {
            guard pendingTransaction.agreementOptionValue, pendingTransaction.termsOptionValue else {
                throw TransactionValidationFailure(state: .optionInvalid)
            }
            guard pendingTransaction.validationState == .canExecute else {
                throw TransactionValidationFailure(state: .unknownError)
            }
        }
    }

    private func checkIfAmountIsBelowMinimumLimit(
        _ pendingTransaction: PendingTransaction
    ) -> Completable {
        Completable.fromCallable {
            guard let minimum = pendingTransaction.minimumLimit else {
                throw TransactionValidationFailure(state: .uninitialized)
            }
            guard try pendingTransaction.amount > minimum else {
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            }
        }
    }
}
