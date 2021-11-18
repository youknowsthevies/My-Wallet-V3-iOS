// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class FiatDepositTransactionEngine: TransactionEngine {

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        .empty()
    }

    let fiatCurrencyService: FiatCurrencyServiceAPI
    let priceService: PriceServiceAPI
    let requireSecondPassword: Bool = false
    let canTransactFiat: Bool = true
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceBankAccount: LinkedBankAccount! {
        sourceAccount as? LinkedBankAccount
    }

    var target: FiatAccount { transactionTarget as! FiatAccount }
    var targetAsset: FiatCurrency { target.fiatCurrency }
    var sourceAsset: FiatCurrency { sourceBankAccount.fiatCurrency }

    // MARK: - Private Properties

    private let paymentMethodsService: PaymentMethodTypesServiceAPI
    private let transactionLimitsService: TransactionLimitsServiceAPI
    private let bankTransferRepository: BankTransferRepositoryAPI

    // MARK: - Init

    init(
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        paymentMethodsService: PaymentMethodTypesServiceAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve(),
        bankTransferRepository: BankTransferRepositoryAPI = resolve()
    ) {
        self.transactionLimitsService = transactionLimitsService
        self.fiatCurrencyService = fiatCurrencyService
        self.paymentMethodsService = paymentMethodsService
        self.priceService = priceService
        self.bankTransferRepository = bankTransferRepository
    }

    // MARK: - TransactionEngine

    func assertInputsValid() {
        precondition(sourceAccount is LinkedBankAccount)
        precondition(transactionTarget is FiatAccount)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        fetchBankTransferLimits(fiatCurrency: target.fiatCurrency)
            .map { [sourceAsset, target] paymentLimits -> PendingTransaction in
                PendingTransaction(
                    amount: .zero(currency: sourceAsset),
                    available: paymentLimits.maximum,
                    feeAmount: .zero(currency: sourceAsset),
                    feeForFullAvailable: .zero(currency: sourceAsset),
                    feeSelection: .init(selectedLevel: .none, availableLevels: []),
                    selectedFiatCurrency: target.fiatCurrency,
                    limits: paymentLimits
                )
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction
            .update(
                confirmations: [
                    .source(.init(value: sourceAccount.label)),
                    .destination(.init(value: target.label)),
                    .transactionFee(.init(fee: pendingTransaction.feeAmount)),
                    .arrivalDate(.default),
                    .total(.init(total: pendingTransaction.amount))
                ]
            )
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction.update(amount: amount))
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        if pendingTransaction.validationState == .uninitialized, pendingTransaction.amount.isZero {
            return .just(pendingTransaction)
        } else {
            return validateAmountCompletable(pendingTransaction: pendingTransaction)
                .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
        }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        sourceAccount
            .receiveAddress
            .map(\.address)
            .flatMap(weak: self) { (self, identifier) -> Single<String> in
                self.bankTransferRepository
                    .startBankTransfer(
                        id: identifier,
                        amount: pendingTransaction.amount
                    )
                    .map(\.paymentId)
                    .asObservable()
                    .asSingle()
            }
            .map { TransactionResult.hashed(txHash: $0, amount: pendingTransaction.amount) }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        .just(event: .completed)
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.feeSelection.availableLevels.contains(level))
        return .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func fetchBankTransferLimits(fiatCurrency: FiatCurrency) -> Single<TransactionLimits> {
        paymentMethodsService
            .eligiblePaymentMethods(for: fiatCurrency)
            .map { paymentMethodTypes -> PaymentMethodType? in
                paymentMethodTypes.first(where: {
                    $0.isSuggested && $0.method == .bankAccount(fiatCurrency.currencyType)
                        || $0.isSuggested && $0.method == .bankTransfer(fiatCurrency.currencyType)
                })
            }
            .flatMap { [transactionLimitsService] paymentMethodType -> Single<TransactionLimits> in
                guard case .suggested(let paymentMethod) = paymentMethodType else {
                    return .just(TransactionLimits.zero(for: fiatCurrency.currencyType))
                }
                return transactionLimitsService.fetchLimits(
                    for: paymentMethod,
                    targetCurrency: fiatCurrency.currencyType,
                    limitsCurrency: fiatCurrency.currencyType
                )
                .asSingle()
            }
    }

    private func validateAmountCompletable(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable { [sourceAccount] in
            guard let transactionLimits = pendingTransaction.limits else {
                throw TransactionValidationFailure(state: .unknownError)
            }
            guard !pendingTransaction.amount.isZero else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
            guard try pendingTransaction.amount >= transactionLimits.minimum else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(transactionLimits.minimum))
            }
            guard try pendingTransaction.amount <= transactionLimits.maximum else {
                throw TransactionValidationFailure(
                    state: .overMaximumSourceLimit(
                        transactionLimits.maximum,
                        sourceAccount!.label,
                        pendingTransaction.amount
                    )
                )
            }
        }
    }
}
