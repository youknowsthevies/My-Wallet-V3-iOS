// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class TradingToOnChainTransactionEngine: TransactionEngine {

    /// This might need to be `1:1` as there isn't a transaction pair.
    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    let walletCurrencyService: FiatCurrencyServiceAPI
    let currencyConversionService: CurrencyConversionServiceAPI
    let requireSecondPassword: Bool = false
    let isNoteSupported: Bool
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceTradingAccount: CryptoTradingAccount! {
        sourceAccount as? CryptoTradingAccount
    }

    var target: CryptoReceiveAddress {
        transactionTarget as! CryptoReceiveAddress
    }

    var targetAsset: CryptoCurrency { target.asset }

    // MARK: - Private Properties

    private let feeCache: CachedValue<CustodialTransferFee>
    private let transferRepository: CustodialTransferRepositoryAPI
    private let transactionLimitsService: TransactionLimitsServiceAPI

    // MARK: - Init

    init(
        isNoteSupported: Bool = false,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve(),
        transactionLimitsService: TransactionLimitsServiceAPI = resolve()
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.isNoteSupported = isNoteSupported
        self.transferRepository = transferRepository
        self.transactionLimitsService = transactionLimitsService
        feeCache = CachedValue(
            configuration: .periodic(
                seconds: 20,
                schedulerIdentifier: "TradingToOnChainTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) -> Single<CustodialTransferFee> in
            self.transferRepository.fees()
                .asSingle()
        }
    }

    func assertInputsValid() {
        precondition(transactionTarget is CryptoReceiveAddress)
        precondition(sourceAsset == targetAsset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        let transactionLimits = transactionLimitsService
            .fetchLimits(
                source: LimitsAccount(
                    currency: sourceAccount.currencyType,
                    accountType: .custodial
                ),
                destination: LimitsAccount(
                    currency: targetAsset.currencyType,
                    accountType: .nonCustodial // even exchange accounts are considered non-custodial atm.
                )
            )
            .asSingle()
        let walletCurrency = walletCurrencyService
            .fiatCurrencyPublisher
            .asSingle()
        return Single
            .zip(
                transactionLimits,
                walletCurrency
            )
            .flatMap { [sourceAsset] transactionLimits, walletCurrency -> Single<PendingTransaction> in
                .just(
                    .init(
                        amount: .zero(currency: sourceAsset),
                        available: .zero(currency: sourceAsset),
                        feeAmount: .zero(currency: sourceAsset),
                        feeForFullAvailable: .zero(currency: sourceAsset),
                        feeSelection: .empty(asset: sourceAsset),
                        selectedFiatCurrency: walletCurrency,
                        limits: transactionLimits
                    )
                )
            }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceTradingAccount != nil else {
            return .just(pendingTransaction)
        }
        return
            Single
                .zip(
                    feeCache.valueSingle,
                    sourceTradingAccount.withdrawableBalance
                )
                .map { fees, withdrawableBalance -> PendingTransaction in
                    let fee = fees[fee: amount.currency]
                    let available = try withdrawableBalance - fee
                    let pendingTransaction = pendingTransaction.update(
                        amount: amount,
                        available: available.isNegative ? .zero(currency: available.currency) : available,
                        fee: fee,
                        feeForFullAvailable: fee
                    )
                    let transactionLimits = pendingTransaction.limits.value ?? .infinity(for: amount.currency)
                    pendingTransaction.limits.value = TransactionLimits(
                        minimum: fees[minimumAmount: amount.currency],
                        maximum: transactionLimits.maximum,
                        maximumDaily: transactionLimits.maximumDaily,
                        maximumAnnual: transactionLimits.maximumAnnual,
                        effectiveLimit: transactionLimits.effectiveLimit,
                        suggestedUpgrade: transactionLimits.suggestedUpgrade
                    )
                    return pendingTransaction
                }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        fiatAmountAndFees(from: pendingTransaction)
            .map(weak: self) { (self, fiatAmountAndFees) -> [TransactionConfirmation] in
                var confirmations: [TransactionConfirmation] = [
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .networkFee(.init(
                        primaryCurrencyFee: fiatAmountAndFees.fees.moneyValue,
                        feeType: .withdrawalFee
                    )),
                    .total(.init(total: fiatAmountAndFees.amount.moneyValue))
                ]
                if self.isNoteSupported {
                    confirmations.append(.destination(.init(value: "")))
                }
                return confirmations
            }
            .map { confirmations -> PendingTransaction in
                pendingTransaction.update(confirmations: confirmations)
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        walletCurrencyService
            .fiatCurrencyPublisher
            .setFailureType(to: PriceServiceError.self)
            .flatMap { [currencyConversionService] fiatCurrency -> AnyPublisher<MoneyValue, PriceServiceError> in
                currencyConversionService.conversionRate(
                    from: pendingTransaction.amount.currencyType,
                    to: fiatCurrency.currencyType
                )
            }
            .zip(
                currencyConversionService.conversionRate(
                    from: sourceAsset.currencyType,
                    to: pendingTransaction.amount.currencyType
                )
            )
            .asSingle()
            .map { [sourceAccount] toWalletRate, toAmountRate -> Void in
                guard let transactionLimits = pendingTransaction.limits.value?.convert(using: toAmountRate) else {
                    throw TransactionValidationFailure(state: .unknownError)
                }
                guard try pendingTransaction.amount >= transactionLimits.minimum else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit(transactionLimits.minimum))
                }
                guard try pendingTransaction.amount <= transactionLimits.maximum else {
                    throw TransactionValidationFailure(
                        state: .overMaximumPersonalLimit(
                            transactionLimits.effectiveLimit,
                            transactionLimits.maximum.convert(using: toWalletRate),
                            transactionLimits.suggestedUpgrade
                        )
                    )
                }
                guard try pendingTransaction.amount <= pendingTransaction.available else {
                    throw TransactionValidationFailure(
                        state: .overMaximumSourceLimit(
                            pendingTransaction.available,
                            sourceAccount!.label,
                            pendingTransaction.amount
                        )
                    )
                }
            }
            .asCompletable()
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        transferRepository
            .transfer(
                moneyValue: pendingTransaction.amount,
                destination: target.address,
                memo: target.memo
            )
            .asObservable()
            .asSingle()
            .map { identifier -> TransactionResult in
                TransactionResult.hashed(txHash: identifier, amount: pendingTransaction.amount)
            }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        target.onTxCompleted(transactionResult)
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.availableFeeLevels.contains(level))
        /// `TradingToOnChainTransactionEngine` only supports a
        /// `FeeLevel` of `.none`
        return .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: sourceCryptoCurrency)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: sourceCryptoCurrency))
        )
        .map { (quote: $0.0.quote.fiatValue ?? .zero(currency: .USD), amount: $0.1, fees: $0.2) }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convertToFiatValue(exchangeRate: quote)
            let fiatFees = fees.convertToFiatValue(exchangeRate: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .fiatCurrency
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency -> Single<MoneyValuePair> in
                currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .asSingle()
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
    }
}
