// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import ToolKit

struct TransactionState: StateType {

    struct KYCStatus: Equatable {
        let tiers: KYC.UserTiers
        let isSDDVerified: Bool

        var canPurchaseCrypto: Bool {
            tiers.canPurchaseCrypto(isSDDVerified: isSDDVerified)
        }

        var canUpgradeTier: Bool {
            tiers.canCompleteTier2
        }
    }

    // MARK: Actual Transaction Data

    let action: AssetAction

    var availableSources: [BlockchainAccount]?
    var availableTargets: [TransactionTarget]?

    var source: BlockchainAccount?
    var destination: TransactionTarget?

    var exchangeRates: TransactionExchangeRates?

    // MARK: Execution Supporting Data

    private var _pendingTransaction: Reference<PendingTransaction>? // struct too big for Swift
    var pendingTransaction: PendingTransaction? {
        get {
            _pendingTransaction?.value
        }
        set {
            if let pendingTransaction = newValue {
                _pendingTransaction = .init(pendingTransaction)
            } else {
                _pendingTransaction = nil
            }
        }
    }

    var executionStatus: TransactionExecutionStatus = .notStarted
    var errorState: TransactionErrorState = .none
    var order: TransactionOrder?

    /// `userKYCStatus` is `nil` until a transaction initializes.
    var userKYCStatus: KYCStatus?

    // MARK: UI Supporting Data

    var allowFiatInput: Bool = false

    // MARK: Second Password Supporting Data

    var passwordRequired: Bool = false
    var secondPassword: String = ""

    // MARK: Navigation Supporting Data

    var nextEnabled: Bool = false
    var isGoingBack: Bool = false

    var step: TransactionFlowStep = .initial {
        didSet {
            isGoingBack = false
        }
    }

    var termsAndAgreementsAreValid: Bool {
        guard action == .interestTransfer else { return true }
        guard let pendingTx = pendingTransaction else { return false }
        return pendingTx.agreementOptionValue && pendingTx.termsOptionValue
    }

    var stepsBackStack: [TransactionFlowStep] = []

    /// The predefined MoneyValue that should be used.
    var initialAmountToSet: MoneyValue? {
        switch destination {
        case let target as ReceiveAddress:
            // The predefined amount is only used if the PendingTransaction has
            // it already set. This means the engine chose to use it.
            let predefinedAmount = target.predefinedAmount
            return predefinedAmount == pendingTransaction?.amount
                ? predefinedAmount : nil
        default:
            return nil
        }
    }

    init(
        action: AssetAction,
        source: BlockchainAccount? = nil,
        destination: TransactionTarget? = nil,
        passwordRequired: Bool = false,
        step: TransactionFlowStep = .initial,
        order: TransactionOrder? = nil
    ) {
        self.action = action
        self.source = source
        self.destination = destination
        self.passwordRequired = passwordRequired
        self.step = step
        self.order = order
    }
}

extension TransactionState {

    private var sourceToFiatPair: MoneyValuePair? {
        guard let sourceCurrencyType = source?.currencyType else {
            return nil
        }
        guard let exchangeRate = exchangeRates?.sourceToFiatTradingCurrencyRate else {
            return nil
        }
        return MoneyValuePair(
            base: .one(currency: sourceCurrencyType),
            exchangeRate: exchangeRate
        )
    }

    private var sourceToDestinationPair: MoneyValuePair? {
        guard let sourceCurrencyType = source?.currencyType else {
            return nil
        }
        guard let exchangeRate = exchangeRates?.sourceToDestinationTradingCurrencyRate else {
            return nil
        }
        return MoneyValuePair(
            base: .one(currency: sourceCurrencyType),
            exchangeRate: exchangeRate
        )
    }

    private var destinationToFiatPair: MoneyValuePair? {
        guard let destinationCurrencyType = destination?.currencyType else {
            return nil
        }
        guard let exchangeRate = exchangeRates?.destinationToFiatTradingCurrencyRate else {
            return nil
        }
        return MoneyValuePair(
            base: .one(currency: destinationCurrencyType),
            exchangeRate: exchangeRate
        )
    }
}

extension TransactionState: Equatable {

    static func == (lhs: TransactionState, rhs: TransactionState) -> Bool {
        lhs.action == rhs.action
            && lhs.allowFiatInput == rhs.allowFiatInput
            && lhs.destination?.label == rhs.destination?.label
            && lhs.exchangeRates == rhs.exchangeRates
            && lhs.errorState == rhs.errorState
            && lhs.executionStatus == rhs.executionStatus
            && lhs.isGoingBack == rhs.isGoingBack
            && lhs.nextEnabled == rhs.nextEnabled
            && lhs.passwordRequired == rhs.passwordRequired
            && lhs.pendingTransaction == rhs.pendingTransaction
            && lhs.secondPassword == rhs.secondPassword
            && lhs.source?.identifier == rhs.source?.identifier
            && lhs.step == rhs.step
            && lhs.stepsBackStack == rhs.stepsBackStack
            && lhs.availableSources?.map(\.identifier) == rhs.availableSources?.map(\.identifier)
            && lhs.availableTargets?.map(\.label) == rhs.availableTargets?.map(\.label)
            && lhs.userKYCStatus == rhs.userKYCStatus
    }
}

// MARK: - Limits

extension TransactionState {

    /// The amount the user is swapping from.
    var amount: MoneyValue {
        normalizedValue(for: pendingTransaction?.amount)
    }

    /// The maximum amount the user can use daily for the given transaction.
    /// This is a different value than the spendable amount (and usually higher)
    var maxDaily: MoneyValue {
        normalizedValue(for: pendingTransaction?.maxSpendableDaily)
    }

    /// The minimum spending limit
    var minSpendable: MoneyValue {
        normalizedValue(for: pendingTransaction?.minSpendable)
    }

    /// The maximum amount the user can spend. We compare the amount entered to the
    /// `maxLimit` as `CryptoValues` and return whichever is smaller.
    var maxSpendable: MoneyValue {
        normalizedValue(for: pendingTransaction?.maxSpendable)
    }

    /// The balance in `MoneyValue` based on the `PendingTransaction`
    var availableBalance: MoneyValue {
        normalizedValue(for: pendingTransaction?.available)
    }

    func maxSpendableWithCryptoInputType() -> MoneyValue {
        maxSpendableWithActiveAmountInputType(.crypto)
    }

    func maxSpendableWithActiveAmountInputType(
        _ input: ActiveAmountInput
    ) -> MoneyValue {
        let amount = normalizedValue(for: pendingTransaction?.maxSpendable)
        return convertMoneyValueToInputCurrency(
            amount.displayableRounding(roundingMode: .down),
            activeInput: input
        )
    }

    func minSpendableWithActiveAmountInputType(
        _ input: ActiveAmountInput
    ) -> MoneyValue {
        let amount = normalizedValue(for: pendingTransaction?.minSpendable)
        return convertMoneyValueToInputCurrency(
            amount.displayableRounding(roundingMode: .up),
            activeInput: input
        )
    }

    private func convertMoneyValueToInputCurrency(
        _ moneyValue: MoneyValue,
        activeInput: ActiveAmountInput
    ) -> MoneyValue {
        switch (moneyValue.currency, activeInput) {
        case (.crypto, .crypto),
             (.fiat, .fiat):
            return moneyValue
        case (.crypto, .fiat):
            // Convert crypto max amount into fiat amount.
            guard let exchangeRate = sourceToFiatPair else {
                // No exchange rate yet, use original value for error message.
                return moneyValue
            }
            // Convert crypto max amount into fiat amount.
            return moneyValue.convert(using: exchangeRate.quote)
        case (.fiat, .crypto):
            guard let exchangeRate = sourceToFiatPair else {
                // No exchange rate yet, use original value for error message.
                return moneyValue
            }
            // Convert fiat max amount into crypto amount.
            return moneyValue.convert(usingInverse: exchangeRate.quote, currency: moneyValue.currency)
        }
    }

    private func normalizedValue(for originalValue: MoneyValue?) -> MoneyValue {
        let zero: MoneyValue = .zero(currency: asset)
        let value = originalValue ?? zero
        return (try? value >= zero) == true ? value : zero
    }
}

// MARK: - Other

extension TransactionState {

    /// The source account `CryptoCurrency`.
    var asset: CurrencyType {
        guard let sourceAccount = source else {
            fatalError("Source should have been set at this point. Asset Action: \(action), Step: \(step)")
        }
        return sourceAccount.currencyType
    }

    /// The fees associated with the transaction
    var feeSelection: FeeSelection {
        guard let pendingTx = pendingTransaction else {
            /// If there is no `pendingTransaction` then the
            /// available fee levels is `[.none]`
            return .empty(asset: asset)
        }
        return pendingTx.feeSelection
    }

    func moneyValueFromSource() -> Result<MoneyValue, FeatureTransactionUIError> {
        guard let rate = sourceToFiatPair else {
            /// A `sourceToFiatPair` is not provided for transactions like a
            /// deposit or a withdraw.
            return .success(amount)
        }
        guard let currency = rate.base.cryptoValue?.currency else {
            return .failure(.unexpectedMoneyValueType(rate.base))
        }
        guard let quote = rate.quote.fiatValue else {
            return .failure(.unexpectedMoneyValueType(rate.quote))
        }
        let pendingTransactionAmount = pendingTransaction?.amount
        switch (pendingTransactionAmount?.cryptoValue, pendingTransactionAmount?.fiatValue) {
        case (.some(let amount), .none):
            /// Just show the `CryptoValue` that the user entered
            /// as this is the `source` currency.
            return .success(.init(cryptoValue: amount))
        case (.none, .some(let amount)):
            /// Convert the `FiatValue` to a `CryptoValue` given the
            /// `quote` from the `sourceToFiatPair` exchange rate.
            return .success(
                amount.convert(
                    usingInverse: quote,
                    currency: currency.currencyType
                )
            )
        default:
            break
        }
        return .success(.zero(currency: currency))
    }

    /// The `MoneyValue` representing the amount received
    /// or the amount that is sent to the given destination.
    func moneyValueFromDestination() -> Result<MoneyValue, FeatureTransactionUIError> {
        let currencyType: CurrencyType
        switch destination {
        case let account as SingleAccount:
            currencyType = account.currencyType
        case let receiveAddress as CryptoReceiveAddress:
            currencyType = receiveAddress.asset.currencyType
        default:
            return .failure(.unexpectedDestinationAccountType)
        }
        guard let exchange = sourceToDestinationPair else {
            return .success(.zero(currency: currencyType))
        }
        guard case .crypto(let currency) = exchange.quote.currency else {
            return .failure(.unexpectedCurrencyType(exchange.quote.currency))
        }
        guard let fiatToSource = sourceToFiatPair?.inverseQuote.quote else {
            return .failure(.emptySourceExchangeRate)
        }
        let pendingTransactionAmount = pendingTransaction?.amount
        switch (
            pendingTransactionAmount?.cryptoValue,
            pendingTransactionAmount?.fiatValue
        ) {
        case (.none, .some(let fiat)):
            // Convert the `FiatValue` amount entered into
            // a `CryptoValue` of source
            // then convert the `CryptoValue` of source to destination
            // using the `quote` of the `sourceToDestinationPair`.
            return .success(
                fiat.convert(using: fiatToSource)
                    .convert(using: exchange.quote)
            )
        case (.some(let crypto), .none):
            // Convert the `CryptoValue` amount entered to destination
            // using the `quote` of the `sourceToDestinationPair`.
            return .success(
                crypto.convert(using: exchange.quote)
            )
        default:
            return .success(.zero(currency: currency))
        }
    }

    /// Converts an FiatValue `available` into CryptoValue if necessary.
    private func availableToAmountCurrency(available: MoneyValue, amount: MoneyValue) -> MoneyValue {
        guard amount.isFiat else {
            return available
        }
        guard let rate = sourceToFiatPair else {
            return .zero(currency: amount.currency)
        }
        return available.convert(using: rate.quote)
    }
}

extension TransactionState {

    var transactionErrorTitle: String {
        errorState.recoveryWarningTitle(for: action).or(Localization.Error.unknownError)
    }

    var transactionErrorDescription: String {
        errorState.recoveryWarningMessage(for: action)
    }
}

enum TransactionFlowStep: Equatable {
    case initial
    case enterPassword
    case selectSource
    case linkPaymentMethod
    case linkACard
    case linkABank
    case linkBankViaWire
    case authorizeOpenBanking
    case enterAddress
    case selectTarget
    case enterAmount
    case kycChecks
    case validateSource
    case confirmDetail
    case inProgress
    case error
    case securityConfirmation
    case errorRecoveryInfo
    case closed
}

extension TransactionFlowStep {

    var addToBackStack: Bool {
        switch self {
        case .selectSource,
             .selectTarget,
             .enterAddress,
             .enterAmount,
             .errorRecoveryInfo,
             .inProgress,
             .linkBankViaWire,
             .confirmDetail:
            return true
        case .closed,
             .enterPassword,
             .initial,
             .kycChecks,
             .error,
             .validateSource,
             .linkPaymentMethod,
             .linkACard,
             .linkABank,
             .securityConfirmation,
             .authorizeOpenBanking:
            return false
        }
    }

    /// Returning `true` indicates that the flow gets automatically dismissed. This is usually the case for independent modal flows.
    var goingBackSkipsNavigation: Bool {
        switch self {
        case .kycChecks,
             .linkPaymentMethod,
             .linkACard,
             .linkABank,
             .linkBankViaWire,
             .securityConfirmation,
             .authorizeOpenBanking:
            return true
        case .closed,
             .confirmDetail,
             .enterAddress,
             .enterAmount,
             .enterPassword,
             .errorRecoveryInfo,
             .inProgress,
             .error,
             .initial,
             .selectSource,
             .selectTarget,
             .validateSource:
            return false
        }
    }
}

enum TransactionExecutionStatus {
    case notStarted
    case inProgress
    case error
    case completed
    case pending

    var isComplete: Bool {
        self == .completed
    }
}
