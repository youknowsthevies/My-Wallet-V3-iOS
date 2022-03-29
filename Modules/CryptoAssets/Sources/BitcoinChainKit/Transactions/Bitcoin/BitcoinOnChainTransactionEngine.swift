// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

// MARK: - Type

private enum BitcoinEngineError: Error {
    case alreadySent
}

final class BitcoinOnChainTransactionEngine<Token: BitcoinChainToken> {

    // MARK: Internal Properties

    let currencyConversionService: CurrencyConversionServiceAPI
    let walletCurrencyService: FiatCurrencyServiceAPI
    let requireSecondPassword: Bool

    var sourceAccount: BlockchainAccount!
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var transactionTarget: TransactionTarget!

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

    // MARK: - Private Properties

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let feeService: AnyCryptoFeeService<BitcoinChainTransactionFee<Token>>
    private let feeCache: CachedValue<BitcoinChainTransactionFee<Token>>
    private let signingService: BitcoinTransactionSigningServiceAPI
    private let sendingService: BitcoinTransactionSendingServiceAPI
    private let buildingService: BitcoinTransactionBuildingServiceAPI
    private let bridge: BitcoinChainSendBridgeAPI
    private let recorder: Recording

    /// didExecuteFlag will be used to log/check if there is an issue
    /// with duplicated txs in the engine.
    private var didExecuteFlag: Bool = false

    private var bitcoinChainCryptoAccount: BitcoinChainCryptoAccount {
        sourceAccount as! BitcoinChainCryptoAccount
    }

    private var receiveAddress: Single<BitcoinChainReceiveAddress<Token>> {
        switch transactionTarget {
        case let target as BitPayInvoiceTarget:
            let address = BitcoinChainReceiveAddress<Token>(
                address: target.address,
                label: target.label,
                onTxCompleted: target.onTxCompleted
            )
            return .just(address)
        case let target as BitcoinChainReceiveAddress<Token>:
            return .just(target)
        case let target as CryptoAccount:
            return target.receiveAddress
                .map { receiveAddress in
                    guard let receiveAddress = receiveAddress as? BitcoinChainReceiveAddress<Token> else {
                        fatalError("Engine requires transactionTarget to be a BitcoinChainReceiveAddress.")
                    }
                    return receiveAddress
                }
        default:
            fatalError("Engine requires transactionTarget to be a BitcoinChainReceiveAddress.")
        }
    }

    // MARK: - Init

    init(
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        requireSecondPassword: Bool,
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        signingService: BitcoinTransactionSigningServiceAPI = resolve(tag: Token.coin),
        sendingService: BitcoinTransactionSendingServiceAPI = resolve(tag: Token.coin),
        buildingService: BitcoinTransactionBuildingServiceAPI = resolve(tag: Token.coin),
        bridge: BitcoinChainSendBridgeAPI = resolve(),
        feeService: AnyCryptoFeeService<BitcoinChainTransactionFee<Token>> = resolve(tag: Token.coin),
        recorder: Recording = resolve(tag: "CrashlyticsRecorder")
    ) {
        self.featureFlagsService = featureFlagsService
        self.requireSecondPassword = requireSecondPassword
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.signingService = signingService
        self.sendingService = sendingService
        self.buildingService = buildingService
        self.bridge = bridge
        self.feeService = feeService
        self.recorder = recorder
        feeCache = CachedValue(
            configuration: .periodic(
                seconds: 90,
                schedulerIdentifier: "BitcoinOnChainTransactionEngine"
            )
        )
        feeCache.setFetch(weak: self) { (self) in
            self.feeService.fees.asSingle()
        }
    }
}

// MARK: - OnChainTransactionEngine

extension BitcoinOnChainTransactionEngine: OnChainTransactionEngine {

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoAccount is BitcoinChainCryptoAccount)
        precondition(sourceCryptoAccount.asset == Token.coin.cryptoCurrency)
    }

    func start(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping (Bool) -> Completable
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }

    func restart(
        transactionTarget: TransactionTarget,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single
            .zip(
                walletCurrencyService
                    .displayCurrency
                    .asSingle(),
                availableBalance,
                featureFlagsService.isEnabled(.local(.nativeBitcoinTransaction)).asSingle()
            )
            .map { [predefinedAmount] fiatCurrency, availableBalance, _ -> PendingTransaction in
                PendingTransaction(
                    amount: predefinedAmount ?? .zero(currency: Token.coin.cryptoCurrency),
                    available: availableBalance,
                    feeAmount: .zero(currency: Token.coin.cryptoCurrency),
                    feeForFullAvailable: .zero(currency: Token.coin.cryptoCurrency),
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular, .priority],
                        asset: Token.coin.cryptoCurrency.currencyType
                    ),
                    selectedFiatCurrency: fiatCurrency,
                    // TODO: update feature flag logic when the feature is complete
                    nativeBitcoinTransactionEnabled: false
                )
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single
            .zip(
                fiatAmountAndFees(from: pendingTransaction),
                makeFeeSelectionOption(pendingTransaction: pendingTransaction)
            )
            .map { fiatAmountAndFees, feeSelectionOption -> (
                amountInFiat: MoneyValue,
                feesInFiat: MoneyValue,
                feeSelectionOption: TransactionConfirmation.Model.FeeSelection
            ) in
                let (amountInFiat, feesInFiat) = fiatAmountAndFees
                return (amountInFiat.moneyValue, feesInFiat.moneyValue, feeSelectionOption)
            }
            .map(weak: self) { (self, payload) -> [TransactionConfirmation] in
                [
                    .sendDestinationValue(.init(value: pendingTransaction.amount)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.transactionTarget.label)),
                    .feeSelection(payload.feeSelectionOption),
                    .feedTotal(
                        .init(
                            amount: pendingTransaction.amount,
                            amountInFiat: payload.amountInFiat,
                            fee: pendingTransaction.feeAmount,
                            feeInFiat: payload.feesInFiat
                        )
                    )
                ]
            }
            // TODO: Apply large transaction warning if necessary
            .map { pendingTransaction.update(confirmations: $0) }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard pendingTransaction.nativeBitcoinTransactionEnabled else {
            return legacyUpdate(amount: amount, pendingTransaction: pendingTransaction)
        }
        return nativeUpdate(amount: amount, pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateOptions(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        guard pendingTransaction.nativeBitcoinTransactionEnabled else {
            return legacyExecute(pendingTransaction: pendingTransaction, secondPassword: secondPassword)
        }
        return nativeExecute(pendingTransaction: pendingTransaction, secondPassword: secondPassword)
    }
}

// MARK: - BitPayClientEngine

extension BitcoinOnChainTransactionEngine: BitPayClientEngine {

    func doPrepareTransaction(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<EngineTransaction> {
        guard pendingTransaction.nativeBitcoinTransactionEnabled else {
            return bridge.sign(with: secondPassword)
        }
        unimplemented()
    }

    func doOnTransactionSuccess(pendingTransaction: PendingTransaction) {
        // This matches Androids API though may not be necessary for iOS
    }

    func doOnTransactionFailed(pendingTransaction: PendingTransaction, error: Error) {
        // This matches Androids API though may not be necessary for iOS
        Logger.shared.error("BitPay transaction failed: \(error)")
    }
}

// MARK: - Helper variables and functions

extension BitcoinOnChainTransactionEngine {

    private var priorityFees: Single<MoneyValue> {
        feeCache
            .valueSingle
            .map(\.priority)
            .map(\.moneyValue)
    }

    private var regularFees: Single<MoneyValue> {
        feeCache
            .valueSingle
            .map(\.regular)
            .map(\.moneyValue)
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [currencyConversionService, sourceCryptoAccount] fiatCurrency in
                currencyConversionService
                    .conversionRate(from: sourceCryptoAccount.currencyType, to: fiatCurrency.currencyType)
                    .map { MoneyValuePair(base: .one(currency: sourceCryptoAccount.currencyType), quote: $0) }
            }
            .asSingle()
    }

    /// Returns the sat/byte fee for the given PendingTransaction.feeLevel.
    private func fee(pendingTransaction: PendingTransaction) -> Single<MoneyValue> {
        switch pendingTransaction.feeLevel {
        case .priority:
            return priorityFees
        case .regular:
            return regularFees
        case .custom:
            return regularFees
        case .none:
            return regularFees
        }
    }

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        guard transactionTarget != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        guard sourceAccount != nil else {
            return .error(TransactionValidationFailure(state: .uninitialized))
        }
        let sourceAccountLabel = sourceAccount.label
        return Completable.fromCallable { [pendingTransaction] in
            guard pendingTransaction.amount.isPositive else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minSpendable))
            }
            guard pendingTransaction.amount.amount >= Token.coin.dust else {
                throw TransactionValidationFailure(state: .belowMinimumLimit(pendingTransaction.minSpendable))
            }
            guard pendingTransaction.amount.amount <= Token.coin.maximumSupply else {
                throw TransactionValidationFailure(
                    state: .overMaximumSourceLimit(
                        MoneyValue(amount: Token.coin.maximumSupply, currency: Token.coin.cryptoCurrency.currencyType),
                        sourceAccountLabel,
                        pendingTransaction.amount
                    )
                )
            }
        }
    }

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        sourceAccount.balance.map { [sourceAccount, transactionTarget] sourceBalance -> Void in
            guard (try? pendingTransaction.amount > pendingTransaction.feeAmount) == true else {
                throw TransactionValidationFailure(
                    state: .belowFees(pendingTransaction.feeAmount, sourceBalance)
                )
            }
            guard (try? pendingTransaction.amount <= pendingTransaction.maxSpendable) == true else {
                throw TransactionValidationFailure(
                    state: .insufficientFunds(
                        pendingTransaction.maxSpendable,
                        pendingTransaction.amount,
                        sourceAccount!.currencyType,
                        transactionTarget!.currencyType
                    )
                )
            }
        }
        .asCompletable()
    }

    private func validateOptions(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            // TODO: Handle custom fees
            guard !pendingTransaction.confirmations.contains(where: { $0.type == .largeTransactionWarning }) else {
                throw TransactionValidationFailure(state: .optionInvalid)
            }
        }
    }

    private func makeFeeSelectionOption(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionConfirmation.Model.FeeSelection> {
        getFeeState(pendingTransaction: pendingTransaction)
            .map { feeState -> TransactionConfirmation.Model.FeeSelection in
                TransactionConfirmation.Model.FeeSelection(
                    feeState: feeState,
                    selectedLevel: pendingTransaction.feeLevel,
                    fee: pendingTransaction.feeAmount
                )
            }
    }

    private func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: Token.coin.cryptoCurrency)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: Token.coin.cryptoCurrency))
        )
        .map { (quote: $0.0.quote.fiatValue ?? .zero(currency: .USD), amount: $0.1, fees: $0.2) }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convert(using: quote)
            let fiatFees = fees.convert(using: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }
}

// MARK: - Native Methods

extension BitcoinOnChainTransactionEngine {

    private func nativeUpdate(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        unimplemented()
    }

    private func nativeExecute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        unimplemented()
    }
}

// MARK: - Legacy Methods

extension BitcoinOnChainTransactionEngine {

    private func legacyUpdate(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard sourceAccount != nil else {
            return .just(pendingTransaction)
        }
        guard let crypto = amount.cryptoValue else {
            preconditionFailure("We should always be passing in `CryptoCurrency` amounts")
        }
        guard crypto.currencyType == Token.coin.cryptoCurrency else {
            preconditionFailure("We should always be passing in BTC amounts's here")
        }
        // For BTC, JS does some internal validation of the proposal. We need to do this in order
        // to run coin selection and get the fee. However, if we pass in a zero value, this is technically
        // incorrect in JS land.
        return Single
            .zip(
                fee(pendingTransaction: pendingTransaction),
                receiveAddress
            )
            .flatMap(weak: self) { (self, values) -> Single<BitcoinChainTransactionProposal<Token>> in
                let (fees, receiveAddress) = values
                return self.bridge.buildProposal(
                    with: receiveAddress,
                    amount: amount,
                    fees: fees,
                    source: self.bitcoinChainCryptoAccount
                )
            }
            .flatMap(weak: self) { (self, proposal) -> Single<BitcoinChainTransactionCandidate<Token>> in
                self.bridge
                    .buildCandidate(with: proposal)
                    .catch { error -> Single<BitcoinChainTransactionCandidate<Token>> in
                        let candidate: BitcoinChainTransactionCandidate<Token>
                        switch error {
                        case BitcoinChainTransactionError.noUnspentOutputs(let finalFee, let sweepAmount, let sweepFee),
                             BitcoinChainTransactionError.belowDustThreshold(let finalFee, let sweepAmount, let sweepFee),
                             BitcoinChainTransactionError.feeTooLow(let finalFee, let sweepAmount, let sweepFee),
                             BitcoinChainTransactionError.unknown(let finalFee, let sweepAmount, let sweepFee):
                            candidate = .init(
                                proposal: proposal,
                                fees: finalFee,
                                sweepAmount: sweepAmount,
                                sweepFee: sweepFee
                            )
                        default:
                            candidate = .init(
                                proposal: proposal,
                                fees: .zero(currency: Token.coin.cryptoCurrency),
                                sweepAmount: .zero(currency: Token.coin.cryptoCurrency),
                                sweepFee: .zero(currency: Token.coin.cryptoCurrency)
                            )
                        }
                        return .just(candidate)
                    }
            }
            .map { candidate -> PendingTransaction in
                pendingTransaction.update(
                    amount: amount,
                    available: candidate.sweepAmount,
                    fee: candidate.fees,
                    feeForFullAvailable: candidate.sweepFee
                )
            }
    }

    private func legacyExecute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        guard !didExecuteFlag else {
            recorder.error(BitcoinEngineError.alreadySent)
            fatalError("BitcoinEngineError.alreadySent")
        }
        didExecuteFlag = true
        return Single
            .zip(
                fee(pendingTransaction: pendingTransaction),
                receiveAddress
            )
            .flatMap(weak: self) { (self, values) -> Single<BitcoinChainTransactionProposal<Token>> in
                let (fees, receiveAddress) = values
                return self.bridge.buildProposal(
                    with: receiveAddress,
                    amount: pendingTransaction.amount,
                    fees: fees,
                    source: self.bitcoinChainCryptoAccount
                )
            }
            .flatMap(weak: self) { (self, proposal) -> Single<BitcoinChainTransactionCandidate<Token>> in
                self.bridge.buildCandidate(with: proposal)
            }
            .flatMap(weak: self) { (self, _) -> Single<String> in
                self.bridge.send(coin: Token.coin, with: secondPassword)
            }
            .map { TransactionResult.hashed(txHash: $0, amount: pendingTransaction.amount) }
    }
}
