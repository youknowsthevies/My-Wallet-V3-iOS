// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class BuyTransactionEngine: TransactionEngine {

    private struct Limits {
        let minimum: MoneyValue
        let maximum: MoneyValue
        let maximumDaily: MoneyValue
        let maximumAnnual: MoneyValue
    }

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    let requireSecondPassword: Bool = false
    let canTransactFiat: Bool = true

    // Used to convert fiat <-> crypto when user types an amount (mainly crypto -> fiat)
    private let conversionService: CurrencyConversionServiceAPI
    // Used to convert payment method currencies into the wallet's default currency
    private let walletCurrencyService: FiatCurrencyServiceAPI
    // Used to convert the user input into an actual quote with fee (takes a fiat amount)
    private let orderQuoteService: OrderQuoteServiceAPI
    // Used to create a pending order when the user confirms the transaction
    private let orderCreationService: OrderCreationServiceAPI
    // Used to execute the order once created
    private let orderConfirmationService: OrderConfirmationServiceAPI

    init(
        conversionService: CurrencyConversionServiceAPI = resolve(),
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        orderQuoteService: OrderQuoteServiceAPI = resolve(),
        orderCreationService: OrderCreationServiceAPI = resolve(),
        orderConfirmationService: OrderConfirmationServiceAPI = resolve()
    ) {
        self.conversionService = conversionService
        self.walletCurrencyService = walletCurrencyService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
        self.orderConfirmationService = orderConfirmationService
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        transactionExchangeRatePair
            .map { quote in
                TransactionMoneyValuePairs(
                    source: quote,
                    destination: quote.inverseExchangeRate
                )
            }
    }

    var fiatExchangeRatePairsSingle: Single<TransactionMoneyValuePairs> {
        fiatExchangeRatePairs
            .take(1)
            .asSingle()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        let cryptoCurrency = transactionTarget.currencyType
        return walletCurrencyService
            .fiatCurrencyObservable
            .map(\.currencyType)
            .flatMap { [conversionService] walletCurrency in
                conversionService
                    .conversionRate(from: cryptoCurrency, to: walletCurrency)
                    .map { quote in
                        MoneyValuePair(
                            base: .one(currency: cryptoCurrency),
                            quote: quote
                        )
                    }
                    .asObservable()
            }
            .share(replay: 1, scope: .whileConnected)
    }

    // Unused but required by `TransactionEngine` protocol
    var askForRefreshConfirmation: (AskForRefreshConfirmation)!

    func assertInputsValid() {
        assert(sourceAccount is PaymentMethodAccount)
        assert(transactionTarget is CryptoAccount)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        makeTransaction()
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        makeTransaction(amount: amount)
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        var transaction = pendingTransaction
        do {
            if try transaction.amount > transaction.maxSpendable {
                transaction.validationState = .overMaximumLimit
            } else if try transaction.amount < transaction.minimumLimit ?? .zero(currency: sourceAccount.currencyType) {
                transaction.validationState = .belowMinimumLimit
            } else {
                transaction.validationState = .canExecute
            }
            return .just(transaction)
        } catch {
            return .error(error)
        }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        let sourceAccountLabel = sourceAccount.label
        return fiatExchangeRatePairsSingle
            .map { moneyPair in
                let fiatAmount: FiatValue
                let cryptoAmount: CryptoValue
                let fiatFeeAmount: FiatValue
                if pendingTransaction.amount.isFiat {
                    fiatAmount = pendingTransaction.amount.fiatValue!
                    fiatFeeAmount = pendingTransaction.feeAmount.fiatValue!
                    cryptoAmount = try pendingTransaction.amount
                        .convert(using: moneyPair.destination)
                        .cryptoValue!
                } else {
                    fiatAmount = try pendingTransaction.amount
                        .convert(using: moneyPair.source)
                        .fiatValue!
                    fiatFeeAmount = try pendingTransaction.feeAmount
                        .convert(using: moneyPair.source)
                        .fiatValue!
                    cryptoAmount = pendingTransaction.amount.cryptoValue!
                }

                var confirmations: [TransactionConfirmation] = [
                    .buyCryptoValue(.init(baseValue: cryptoAmount)),
                    .buyExchangeRateValue(.init(baseValue: moneyPair.source.quote, code: moneyPair.source.base.code)),
                    .buyPaymentMethod(.init(name: sourceAccountLabel)),
                    .transactionFee(.init(fee: fiatFeeAmount.moneyValue)),
                    .total(.init(total: (try fiatAmount + fiatFeeAmount).moneyValue))
                ]
                if let customFeeAmount = pendingTransaction.customFeeAmount {
                    confirmations.append(.transactionFee(.init(fee: customFeeAmount)))
                }
                return pendingTransaction.update(confirmations: confirmations)
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        // STEP 1: Get a fresh quote for the transaction
        return fetchQuote(for: pendingTransaction.amount)
            // STEP 2: Create an Order for the transaction
            .flatMap { [orderCreationService] refreshedQuote -> Single<CheckoutData> in
                let paymentMethodId: String?
                if sourceAccount.paymentMethod.type.isFunds {
                    // NOTE: This fixes IOS-5389
                    paymentMethodId = nil
                } else {
                    paymentMethodId = sourceAccount.paymentMethodType.id
                }
                let orderDetails = CandidateOrderDetails.buy(
                    paymentMethod: sourceAccount.paymentMethodType,
                    fiatValue: refreshedQuote.estimatedFiatAmount,
                    cryptoValue: refreshedQuote.estimatedCryptoAmount,
                    paymentMethodId: paymentMethodId
                )
                return orderCreationService.create(using: orderDetails)
            }
            .do(onError: { error in
                Logger.shared.error("[BUY] Order creation failed \(String(describing: error))")
            })
            // STEP 3: Execute the order
            .flatMap { [orderConfirmationService] checkoutData -> Single<CheckoutData> in
                Logger.shared.info("[BUY] Order creation successful \(String(describing: checkoutData))")
                return orderConfirmationService.confirm(checkoutData: checkoutData)
            }
            // STEP 4: Map order to Transaction Result
            .map { checkoutData -> TransactionResult in
                Logger.shared.info("[BUY] Order confirmation successful \(String(describing: checkoutData))")
                return TransactionResult.hashed(
                    txHash: checkoutData.order.identifier,
                    amount: pendingTransaction.amount,
                    order: checkoutData.order
                )
            }
            .do(onError: { error in
                Logger.shared.error("[BUY] Order confirmation failed \(String(describing: error))")
            })
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        transactionTarget.onTxCompleted(transactionResult)
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        impossible("Fees are fixed for buying crypto")
    }

    // MARK: - Helpers

    private func makeTransaction(amount: MoneyValue? = nil) -> Single<PendingTransaction> {
        guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        let paymentMethod = sourceAccount.paymentMethod
        let amount = amount ?? .zero(currency: paymentMethod.fiatCurrency.currencyType)
        return Publishers.Zip3(
            convertSourceBalance(to: amount.currencyType),
            fetchFeeForPurchasing(amount),
            convertTransactionLimits(for: paymentMethod, to: amount.currencyType)
        )
        .tryMap { sourceBalance, quoteFee, limits in
            PendingTransaction(
                amount: amount,
                available: sourceBalance,
                feeAmount: quoteFee,
                feeForFullAvailable: quoteFee,
                feeSelection: .empty(asset: amount.currencyType),
                selectedFiatCurrency: sourceAccount.fiatCurrency,
                minimumLimit: limits.minimum,
                maximumLimit: try MoneyValue.min(sourceBalance, limits.maximum),
                maximumDailyLimit: limits.maximumDaily,
                maximumAnnualLimit: limits.maximumAnnual
            )
        }
        .flatMap { [validateAmount] transaction in
            validateAmount(transaction)
                .asPublisher()
        }
        .asSingle()
    }

    private func fetchQuote(for amount: MoneyValue) -> Single<Quote> {
        guard let destination = transactionTarget as? CryptoAccount else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        return convertAmountIntoWalletFiatCurrency(amount)
            .flatMap { [orderQuoteService] fiatValue in
                orderQuoteService.getQuote(
                    for: .buy,
                    cryptoCurrency: destination.asset,
                    fiatValue: fiatValue
                )
            }
    }

    private func convertAmountIntoWalletFiatCurrency(_ amount: MoneyValue) -> Single<FiatValue> {
        fiatExchangeRatePairsSingle
            .map { moneyPair in
                guard !amount.isFiat else {
                    return amount.fiatValue!
                }
                return try amount
                    .convert(using: moneyPair.source)
                    .fiatValue!
            }
    }

    private func convertSourceBalance(to currency: CurrencyType) -> AnyPublisher<MoneyValue, PriceServiceError> {
        sourceAccount
            .balance
            .asPublisher()
            .replaceError(with: PriceServiceError.missingPrice)
            .flatMap { [conversionService] balance in
                conversionService.convert(balance, to: currency)
            }
            .eraseToAnyPublisher()
    }

    private func fetchFeeForPurchasing(_ amount: MoneyValue) -> AnyPublisher<MoneyValue, PriceServiceError> {
        fetchQuote(for: amount)
            .map(\.fee.moneyValue)
            .asPublisher()
            .replaceError(with: PriceServiceError.missingPrice)
            .flatMap { [conversionService] quoteFee in
                conversionService.convert(quoteFee, to: amount.currencyType)
            }
            .eraseToAnyPublisher()
    }

    private func convertTransactionLimits(
        for paymentMethod: PaymentMethod,
        to targetCurrency: CurrencyType
    ) -> AnyPublisher<Limits, PriceServiceError> {
        conversionService
            .conversionRate(from: paymentMethod.min.currencyType, to: targetCurrency)
            .map { conversionRate in
                Limits(
                    minimum: paymentMethod.min.moneyValue.convert(using: conversionRate),
                    maximum: paymentMethod.max.moneyValue.convert(using: conversionRate),
                    maximumDaily: paymentMethod.maxDaily.moneyValue.convert(using: conversionRate),
                    maximumAnnual: paymentMethod.maxAnnual.moneyValue.convert(using: conversionRate)
                )
            }
            .eraseToAnyPublisher()
    }
}
