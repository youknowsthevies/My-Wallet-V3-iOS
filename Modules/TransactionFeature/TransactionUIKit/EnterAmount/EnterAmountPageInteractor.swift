// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import TransactionKit

protocol EnterAmountPageRouting: AnyObject {
    func showFeeSelectionSheet(with transactionModel: TransactionModel)
    func showError()
}

protocol EnterAmountPageListener: AnyObject {
    func enterAmountDidTapBack()
    func closeFlow()
    func continueToKYCTiersScreen()
    func showGenericFailure()
}

protocol EnterAmountPagePresentable: Presentable {
    var continueButtonTapped: Signal<Void> { get }
    func connect(state: Driver<EnterAmountPageInteractor.State>) -> Driver<EnterAmountPageInteractor.NavigationEffects>
}

final class EnterAmountPageInteractor: PresentableInteractor<EnterAmountPagePresentable>,
                                       EnterAmountPageInteractable {

    weak var router: EnterAmountPageRouting?
    weak var listener: EnterAmountPageListener?

    /// The interactor that `SendAuxiliaryViewPresenter` uses
    private let sendAuxiliaryViewInteractor: SendAuxiliaryViewInteractor
    private let sendAuxiliaryViewPresenter: SendAuxiliaryViewPresenter

    private let accountAuxiliaryViewInteractor: AccountAuxiliaryViewInteractor
    private let accountAuxiliaryViewPresenter: AccountAuxiliaryViewPresenter
    /// The interactor that `SingleAmountPreseneter` uses
    private let amountViewInteractor: AmountViewInteracting

    private let transactionModel: TransactionModel
    private let analyticsHook: TransactionAnalyticsHook
    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel

    init(transactionModel: TransactionModel,
         presenter: EnterAmountPagePresentable,
         amountInteractor: AmountViewInteracting,
         action: AssetAction,
         navigationModel: ScreenNavigationModel,
         analyticsHook: TransactionAnalyticsHook = resolve()) {
        self.action = action
        self.transactionModel = transactionModel
        self.amountViewInteractor = amountInteractor
        self.navigationModel = navigationModel
        self.analyticsHook = analyticsHook
        self.sendAuxiliaryViewInteractor = SendAuxiliaryViewInteractor()
        sendAuxiliaryViewPresenter = SendAuxiliaryViewPresenter(
            interactor: sendAuxiliaryViewInteractor
        )
        self.accountAuxiliaryViewInteractor = AccountAuxiliaryViewInteractor()
        self.accountAuxiliaryViewPresenter = AccountAuxiliaryViewPresenter(
            interactor: accountAuxiliaryViewInteractor
        )
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let transactionState: Observable<TransactionState> = transactionModel
            .state
            .share(replay: 1, scope: .whileConnected)

        amountViewInteractor
            .effect
            .subscribe { [weak self] effect  in
                self?.handleAmountTranslation(effect: effect)
            }
            .disposeOnDeactivate(interactor: self)

        amountViewInteractor
            .amount
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { (amount) -> Observable<MoneyValue> in
                transactionState
                    .take(1)
                    .asSingle()
                    .map { state in
                        if let fiat = amount.fiatValue, !state.allowFiatInput {
                            // Fiat Input but state does not allow fiat
                            guard let sourceToFiatPair = state.sourceToFiatPair else {
                                return MoneyValue.zero(currency: state.asset)
                            }
                            return MoneyValuePair(
                                fiat: fiat,
                                priceInFiat: sourceToFiatPair.quote.fiatValue!,
                                cryptoCurrency: state.asset.cryptoCurrency!,
                                usesFiatAsBase: true
                            ).quote
                        }
                        return amount
                    }
                    .asObservable()
            }
            .subscribe { [weak self] (amount: MoneyValue) in
                self?.transactionModel.process(action: .updateAmount(amount))
            }
            .disposeOnDeactivate(interactor: self)

        let spendable = Observable
            .combineLatest(
                transactionState,
                amountViewInteractor.activeInput
            )
            .map { (state, input) in
                (
                    min: state.minSpendable.displayableRounding(roundingMode: .up),
                    max: state.maxSpendable.displayableRounding(roundingMode: .down),
                    errorState: state.errorState,
                    exchangeRate: state.sourceToFiatPair,
                    activeInput: input,
                    amount: state.amount
                )
            }
            .share(scope: .whileConnected)

        transactionState
            .distinctUntilChanged(\.feeSelection, comparer: { $0 == $1 })
            .filter { $0.feeSelection.selectedLevel != .none }
            .subscribe(onNext: { [analyticsHook] state in
                analyticsHook.onFeeSelected(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        let fee = transactionState
            .takeWhile { $0.action == .send }
            .compactMap(\.pendingTransaction)
            .map(\.feeAmount)
            .share(scope: .whileConnected)

        let bank = transactionState
            .takeWhile { $0.action == .withdraw || $0.action == .deposit }
            .map { state -> BlockchainAccount? in
                switch state.action {
                case .withdraw:
                    return state.destination as? BlockchainAccount
                case .deposit:
                    return state.source
                case .viewActivity,
                     .buy,
                     .sell,
                     .send,
                     .receive,
                     .swap:
                    fatalError("Expected either withdraw or deposit")
                }
            }
            .compactMap { $0 }
            .share(scope: .whileConnected)

        accountAuxiliaryViewInteractor
            .connect(stream: bank)
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .connect(fee: fee)
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .connect(stream: spendable.map(\.max))
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .resetToMaxAmount
            .withLatestFrom(spendable.map(\.max))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountViewInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .resetToMaxAmount
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [analyticsHook] state in
                analyticsHook.onMaxSelected(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .availableBalanceTapped
            .withLatestFrom(spendable.map(\.max))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountViewInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .networkFeeTapped
            .bindAndCatch(weak: self) { (self, _) in
                self.router?.showFeeSelectionSheet(with: self.transactionModel)
            }
            .disposeOnDeactivate(interactor: self)

        spendable
            .map { [weak listener] spendable in
                spendable.errorState.toAmountInteractorState(
                    min: spendable.min,
                    max: spendable.max,
                    exchangeRate: spendable.exchangeRate,
                    activeInput: spendable.activeInput,
                    stateAmount: spendable.amount,
                    listener: listener
                )
            }
            .bindAndCatch(to: amountViewInteractor.stateRelay)
            .disposeOnDeactivate(interactor: self)

        let interactorState = transactionState
            .scan(initialState()) { [weak self] (currentState, updater) -> State in
                guard let self = self else {
                    return currentState
                }
                return self.calculateNextState(
                    with: currentState,
                    updater: updater
                )
            }
            .asDriverCatchError()

        presenter
            .continueButtonTapped
            .asObservable()
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [weak self] state in
                self?.transactionModel.process(action: .prepareTransaction)
                self?.analyticsHook.onEnterAmountContinue(with: state)
            })
            .disposeOnDeactivate(interactor: self)

        presenter
            .connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)

        transactionState
            .compactMap { state -> (action: AssetAction,
                                    amountIsZero: Bool,
                                    networkFeeAdjustmentSupported: Bool)? in
                guard let pendingTransaction = state.pendingTransaction else {
                    return nil
                }
                return (state.action,
                        state.amount.isZero,
                        pendingTransaction.availableFeeLevels.networkFeeAdjustmentSupported)
            }
            .map { (action, amountIsZero, networkFeeAdjustmentSupported) in
                (action, (networkFeeAdjustmentSupported && action == .send && !amountIsZero) ? .visible : .hidden)
            }
            .map { (action, networkFeeVisibility) -> SendAuxiliaryViewPresenter.State in
                SendAuxiliaryViewPresenter.State(
                    maxButtonVisibility: networkFeeVisibility.inverted,
                    networkFeeVisibility: networkFeeVisibility,
                    bitpayVisibility: .hidden,
                    availableBalanceTitle: TransactionFlowDescriptor.availableBalanceTitle,
                    maxButtonTitle: TransactionFlowDescriptor.maxButtonTitle(action: action)
                )
            }
            .bindAndCatch(to: sendAuxiliaryViewPresenter.stateRelay)
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func calculateNextState(
        with state: State,
        updater: TransactionState
    ) -> State {
        let topSelectionTitle = TransactionFlowDescriptor.EnterAmountScreen.headerTitle(state: updater)
        let topSelectionSubtitle = TransactionFlowDescriptor.EnterAmountScreen.headerSubtitle(state: updater)
        let topSelection = TopSelectionState(
            sourceAccount: updater.source,
            destinationAccount: updater.destination as? BlockchainAccount,
            action: updater.action,
            titleAccessibility: .label(topSelectionTitle),
            subtitleAccessibility: .label(topSelectionSubtitle)
        )

        return state
            .update(\.canContinue, value: updater.nextEnabled)
            .update(\.topSelection, value: topSelection)
            .update(\.topSelection.title, value: topSelectionTitle)
            .update(\.topSelection.subtitle, value: topSelectionSubtitle)
    }

    private func handle(effects: NavigationEffects) {
        switch effects {
        case .back:
            listener?.enterAmountDidTapBack()
        case .close:
            listener?.closeFlow()
        case .none:
            break
        }
    }

    private func handleAmountTranslation(effect: AmountInteractorEffect) {
        switch effect {
        case .failure:
            listener?.showGenericFailure()
        case .none:
            break
        }
    }

    private func initialState() -> State {
        let topSelectionState = TopSelectionState(
            sourceAccount: nil,
            destinationAccount: nil,
            action: action
        )
        let send = BottomAuxiliaryViewModelState.send(
            sendAuxiliaryViewPresenter
        )
        let account = BottomAuxiliaryViewModelState.account(
            accountAuxiliaryViewPresenter
        )

        let bottom = action == .deposit || action == .withdraw ? account : send

        return State(
            topSelection: topSelectionState,
            bottomAuxiliaryState: bottom,
            navigationModel: navigationModel,
            canContinue: false
        )
    }
}

extension EnterAmountPageInteractor {
    struct State {
        var topSelection: TopSelectionState
        var bottomAuxiliaryState: BottomAuxiliaryViewModelState
        var navigationModel: ScreenNavigationModel
        var canContinue: Bool
    }

    /// The state of the top selection view
    struct TopSelectionState {
        var title: String = ""
        var titleDescriptor: (font: UIFont, textColor: UIColor)
        var subtitle: String = ""
        var subtitleDescriptor: (font: UIFont, textColor: UIColor)
        let isEnabled: Bool = false
        var trailingContent: SelectionButtonViewModel.TrailingContent
        var leadingContent: SelectionButtonViewModel.LeadingContentType?
        var titleAccessibility: Accessibility = .none
        var subtitleAccessibility: Accessibility = .none
        var accessibilityContent: SelectionButtonViewModel.AccessibilityContent?

        private init(titleDescriptor: (font: UIFont, textColor: UIColor),
                     subtitleDescriptor: (font: UIFont, textColor: UIColor),
                     trailingContent: SelectionButtonViewModel.TrailingContent,
                     leadingContent: SelectionButtonViewModel.LeadingContentType?,
                     accessibilityContent: SelectionButtonViewModel.AccessibilityContent?,
                     titleAccessibility: Accessibility,
                     subtitleAccessibility: Accessibility) {
            self.titleDescriptor = titleDescriptor
            self.subtitleDescriptor = subtitleDescriptor
            self.trailingContent = trailingContent
            self.leadingContent = leadingContent
            self.accessibilityContent = accessibilityContent
            self.titleAccessibility = titleAccessibility
            self.subtitleAccessibility = subtitleAccessibility
        }

        init(sourceAccount: BlockchainAccount?,
             destinationAccount: BlockchainAccount?,
             action: AssetAction,
             titleAccessibility: Accessibility = .none,
             subtitleAccessibility: Accessibility = .none) {
            let transactionImageViewModel = TransactionDescriptorViewModel(
                sourceAccount: sourceAccount as? SingleAccount,
                destinationAccount: action == .swap ? destinationAccount as? SingleAccount : nil,
                assetAction: action,
                adjustActionIconColor: action == .swap ? false : true
            )
            self.init(
                titleDescriptor: (font: .main(.medium, 12.0), textColor: .descriptionText),
                subtitleDescriptor: (font: .main(.semibold, 14.0), textColor: .titleText),
                trailingContent: .transaction(transactionImageViewModel),
                leadingContent: .none,
                accessibilityContent: nil,
                titleAccessibility: titleAccessibility,
                subtitleAccessibility: subtitleAccessibility
            )
        }
    }

    /// The state of the bottom auxiliary view
    enum BottomAuxiliaryViewModelState {

        /// Account style view that shows the `LinkedBankAccount` that the
        /// user is depositing from or withdrawing to.
        case account(AccountAuxiliaryViewPresenter)

        /// Max available style button with available amount for spending and use-maximum button
        case send(SendAuxiliaryViewPresenter)

        /// Hidden - nothing to present
        case hidden
    }

}

extension EnterAmountPageInteractor {
    enum NavigationEffects {
        case back
        case close
        case none
    }
}

extension EnterAmountPageInteractor.State {
    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }
}

extension EnterAmountPageInteractor.BottomAuxiliaryViewModelState: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.hidden, .hidden):
            return true
        case (.send, .send):
            return true
        case (.account, .account):
            return true
        default:
            return false
        }
    }
}

extension TransactionErrorState {
    private typealias LocalizedString = LocalizationConstants.Transaction
    func toAmountInteractorState(min: MoneyValue,
                                 max: MoneyValue,
                                 exchangeRate: MoneyValuePair?,
                                 activeInput: ActiveAmountInput,
                                 stateAmount:  MoneyValue,
                                 listener: EnterAmountPageListener?) -> AmountInteractorState {
        switch self {
        case .none:
            return .inBounds
        case .insufficientGas:
            return .error(
                message: LocalizedString.Confirmation.Error.insufficientGas
            )
        case .overSilverTierLimit:
            return .warning(
                message: LocalizedString.Swap.KYC.overSilverLimitWarning,
                action: { [weak listener] in
                    listener?.continueToKYCTiersScreen()
                }
            )
        case .overGoldTierLimit,
             .overMaximumLimit,
             .insufficientFundsForFees,
             .insufficientFunds:
            let result = convertToInputCurrency(max, exchangeRate: exchangeRate, input: activeInput)
            return .maxLimitExceeded(result)
        case .belowMinimumLimit:
            guard !stateAmount.isZero else {
                return .inBounds
            }
            let result = convertToInputCurrency(min, exchangeRate: exchangeRate, input: activeInput)
            return .underMinLimit(result)
        case .addressIsContract,
             .invalidAddress,
             .invalidAmount,
             .invalidPassword,
             .optionInvalid,
             .transactionInFlight,
             .pendingOrdersLimitReached,
             .unknownError,
             .nabuError,
             .fatalError:
            return .empty
        }
    }

    private func convertToInputCurrency(_ source: MoneyValue, exchangeRate: MoneyValuePair?, input: ActiveAmountInput) -> MoneyValue {
        switch (source.currencyType, input) {
        case (.crypto, .crypto),
             (.fiat, .fiat):
            return source
        case (.crypto, .fiat):
            // Convert crypto max amount into fiat amount.
            guard let exchangeRate = exchangeRate else {
                // No exchange rate yet, use original value for error message.
                return source
            }
            // Convert crypto max amount into fiat amount.
            guard let result = try? source.convert(using: exchangeRate.quote) else {
                // Can't convert, use original value for error message.
                return source
            }
            return result
        case (.fiat, .crypto):
            Swift.fatalError("Shouldn't happen for the implemented paths (Swap).")
        }
    }
}
