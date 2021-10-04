// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class BuyTransactionEngine: TransactionEngine {

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    let requireSecondPassword: Bool = false
    let canTransactFiat: Bool = true

    // Used to convert fiat <-> crypto when user types an amount (mainly crypto -> fiat)
    private let priceService: PriceServiceAPI
    // Used to convert the user input into an actual quote with fee (takes a fiat amount)
    private let orderQuoteService: OrderQuoteServiceAPI
    // Used to create a pending order when the user confirms the transaction
    private let orderCreationService: OrderCreationServiceAPI
    // Used to execute the order once created
    private let orderConfirmationService: OrderConfirmationServiceAPI

    init(
        priceService: PriceServiceAPI = resolve(),
        orderQuoteService: OrderQuoteServiceAPI = resolve(),
        orderCreationService: OrderCreationServiceAPI = resolve(),
        orderConfirmationService: OrderConfirmationServiceAPI = resolve()
    ) {
        self.priceService = priceService
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

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        fetchExchangeRate(from: transactionTarget.currencyType, to: sourceAccount.currencyType)
            .share(replay: 1, scope: .whileConnected)
    }

    var askForRefreshConfirmation: (AskForRefreshConfirmation)! // TODO: use this

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
        .just(pendingTransaction)
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        transactionExchangeRatePair
            .asSingle()
            .flatMap { [sourceAccount] moneyPair in
                let cryptoValue = pendingTransaction.amount.convert(
                    using: moneyPair.inverseExchangeRate.quote
                ).cryptoValue!

                var confirmations: [TransactionConfirmation] = [
                    .buyCryptoValue(.init(baseValue: cryptoValue)),
                    .buyExchangeRateValue(.init(baseValue: moneyPair.quote, code: moneyPair.base.code)),
                    .buyPaymentMethod(.init(name: sourceAccount?.label ?? "")),
                    .transactionFee(.init(fee: pendingTransaction.feeAmount)),
                    .total(.init(total: try pendingTransaction.amount + pendingTransaction.feeAmount))
                ]
                if let customFeeAmount = pendingTransaction.customFeeAmount {
                    confirmations.append(.transactionFee(.init(fee: customFeeAmount)))
                }
                return Single.just(pendingTransaction.update(confirmations: confirmations))
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
                let orderDetails = CandidateOrderDetails.buy(
                    paymentMethod: sourceAccount.paymentMethodType,
                    fiatValue: refreshedQuote.estimatedFiatAmount,
                    cryptoValue: refreshedQuote.estimatedCryptoAmount,
                    paymentMethodId: sourceAccount.paymentMethodType.id
                )
                return orderCreationService.create(using: orderDetails)
            }
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
                Logger.shared.error("[BUY] Order failed \(String(describing: error))")
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

    private func convertAmountIntoSourceFiatCurrency(_ amount: MoneyValue) -> Single<FiatValue> {
        if let fiatValue = amount.fiatValue {
            return .just(fiatValue)
        }
        return fiatExchangeRatePairs
            .take(1)
            .asSingle()
            .map { exchangeRatePairs in
                guard let fiatValue = try amount.convert(using: exchangeRatePairs.source).fiatValue else {
                    impossible("The conversion's result must be a fiat amount.")
                }
                return fiatValue
            }
    }

    private func fetchQuote(for amount: MoneyValue) -> Single<Quote> {
        guard let destination = transactionTarget as? CryptoAccount else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        return convertAmountIntoSourceFiatCurrency(amount)
            .flatMap { [orderQuoteService] fiatValue in
                orderQuoteService.getQuote(
                    for: .buy,
                    cryptoCurrency: destination.asset,
                    fiatValue: fiatValue
                )
            }
    }

    private func makeTransaction(amount: MoneyValue? = nil) -> Single<PendingTransaction> {
        guard let sourceAccount = sourceAccount as? PaymentMethodAccount else {
            return .error(TransactionValidationFailure(state: .optionInvalid))
        }
        let amount = amount ?? .zero(currency: sourceAccount.currencyType)
        let paymentMethod = sourceAccount.paymentMethod
        return Single.zip(
            sourceAccount.balance,
            fetchQuote(for: amount)
        )
        .map { sourceBalance, quote in
            PendingTransaction(
                amount: amount,
                available: sourceBalance,
                feeAmount: quote.fee.moneyValue,
                feeForFullAvailable: quote.fee.moneyValue,
                feeSelection: .empty(asset: sourceAccount.currencyType),
                selectedFiatCurrency: sourceAccount.fiatCurrency,
                minimumLimit: paymentMethod.min.moneyValue,
                maximumLimit: try MoneyValue.min(sourceBalance, paymentMethod.max.moneyValue),
                maximumDailyLimit: paymentMethod.maxDaily.moneyValue,
                maximumAnnualLimit: paymentMethod.maxAnnual.moneyValue
            )
        }
        .flatMap(weak: self) { (self, transaction) in
            self.validateAmount(pendingTransaction: transaction)
        }
    }

    private func fetchExchangeRate(from source: CurrencyType, to target: CurrencyType) -> Observable<MoneyValuePair> {
        priceService.price(of: source, in: target)
            .asObservable()
            .map(\.moneyValue)
            .map { quote in
                MoneyValuePair(base: .one(currency: source), quote: quote)
            }
    }
}
