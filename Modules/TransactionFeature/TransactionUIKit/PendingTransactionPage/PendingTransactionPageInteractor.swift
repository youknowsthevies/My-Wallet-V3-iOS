// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import TransactionKit

protocol PendingTransactionPageRouting: Routing {
}

protocol PendingTransactionPageListener: AnyObject {
    func closeFlow()
}

protocol PendingTransactionPagePresentable: Presentable, PendingTransactionPageViewControllable {
    func connect(state: Driver<PendingTransactionPageInteractor.State>) -> Driver<PendingTransactionPageInteractor.Effects>
}

final class PendingTransactionPageInteractor: PresentableInteractor<PendingTransactionPagePresentable>, PendingTransactionPageInteractable {

    weak var router: PendingTransactionPageRouting?
    weak var listener: PendingTransactionPageListener?

    private let transactionModel: TransactionModel
    private let analyticsHook: TransactionAnalyticsHook

    private lazy var crashOnError: Bool = {
        #if INTERNAL_BUILD
        return true
        #else
        return false
        #endif
    }()

    init(transactionModel: TransactionModel,
         presenter: PendingTransactionPagePresentable,
         analyticsHook: TransactionAnalyticsHook = resolve()) {
        self.transactionModel = transactionModel
        self.analyticsHook = analyticsHook
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let transactionState = transactionModel.state
            .share(replay: 1)
        let sent: Observable<MoneyValue> = transactionState
            .map { [crashOnError] state -> MoneyValue in
                switch state.moneyValueFromSource() {
                case .success(let value):
                    return value
                case .failure(let error):
                    guard let source = state.source else {
                        fatalError("No state.source")
                    }
                    if crashOnError {
                        fatalError(String(describing: error))
                    }
                    return .zero(currency: source.currencyType)
                }
            }

        let received: Observable<MoneyValue?> = transactionState
            .map { [crashOnError] state -> MoneyValue? in
                switch state.moneyValueFromDestination() {
                case .success(let value):
                    return value
                case .failure(let error):
                    if crashOnError {
                        fatalError(String(describing: error))
                    }
                    switch state.destination {
                    case nil:
                        return nil
                    case let account as SingleAccount:
                        return MoneyValue.zero(currency: account.currencyType)
                    case let cryptoTarget as CryptoTarget:
                        return MoneyValue.zero(currency: cryptoTarget.asset)
                    default:
                        fatalError("Unsupported state.destination: \(String(reflecting: state.destination))")
                    }
                }
            }

        let destination = transactionState.compactMap(\.destination)
        let executionStatus = transactionState.map(\.executionStatus)

        let interactorState = Observable
            .combineLatest(sent, received, destination, transactionState)
            .map { (values) -> State in
                let (sent, received, destination, transactionState) = values
                let action = transactionState.action
                switch transactionState.executionStatus {
                case .completed:
                    return .complete(amount: sent, destination: destination, action: action)
                case .error:
                    return .failed(transactionState: transactionState, action: action)
                case .inProgress, .notStarted:
                    return .pending(action: action, sent: sent, received: received)
                }
            }
            .asDriverCatchError()

        executionStatus
            .asObservable()
            .withLatestFrom(transactionState) { ($0, $1) }
            .subscribe(onNext: { [weak self] (executionStatus, transactionState) in
                switch executionStatus {
                case .inProgress, .notStarted:
                    break
                case .error:
                    self?.analyticsHook.onTransactionFailure(with: transactionState)
                case .completed:
                    self?.analyticsHook.onTransactionSuccess(with: transactionState)
                }
            })
            .disposeOnDeactivate(interactor: self)

        let completion = executionStatus
            .map(\.isComplete)
            .filter { $0 == true }
            .delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .asDriverCatchError()

        completion
            .drive(weak: self) { (self, _) in
                self.requestReview()
            }
            .disposeOnDeactivate(interactor: self)

        presenter.connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func requestReview() {
        StoreReviewController.requestReview()
    }

    private func handle(effects: Effects) {
        switch effects {
        case .close:
            listener?.closeFlow()
        case .none:
            break
        }
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

extension PendingTransactionPageInteractor {
    typealias SwapLocalizationIds = LocalizationConstants.Transaction.Swap.Completion
    typealias SendLocalizationIds = LocalizationConstants.Transaction.Send.Completion

    // TODO: Inject Accessibility

    struct State {
        var title: LabelContent
        var subtitle: LabelContent
        var compositeViewType: CompositeStatusViewType
        var buttonViewModel: ButtonViewModel?
        var buttonViewModelVisibility: Visibility {
            buttonViewModel == nil ? .hidden : .visible
        }
        let effects: PendingTransactionPageInteractor.Effects

        private static var crashOnError: Bool = {
            #if INTERNAL_BUILD
            return true
            #else
            return false
            #endif
        }()

        private init(title: String,
                     subtitle: String,
                     compositeViewType: CompositeStatusViewType,
                     effects: PendingTransactionPageInteractor.Effects = .none,
                     buttonViewModel: ButtonViewModel?) {
            self.title = .init(
                text: title,
                font: .main(.semibold, 20.0),
                color: .titleText,
                alignment: .center,
                accessibility: .none
            )

            self.subtitle = .init(
                text: subtitle,
                font: .main(.medium, 14.0),
                color: .descriptionText,
                alignment: .center,
                accessibility: .none
            )

            self.compositeViewType = compositeViewType
            self.buttonViewModel = buttonViewModel
            self.effects = effects
        }

        static func complete(amount: MoneyValue,
                             destination: TransactionTarget,
                             action: AssetAction) -> State {
            let asset: CurrencyType
            switch destination {
            case let cryptoTarget as CryptoTarget:
                asset = cryptoTarget.asset.currency
            case let account as SingleAccount:
                asset = account.currencyType
            default:
                fatalError("Unsupported destination")
            }
            switch action {
            case .send:
                let localImage = asset.logoResource.local
                return .init(
                    title: String(
                        format: SendLocalizationIds.Success.title,
                        amount.displayString
                    ),
                    subtitle: String(
                        format: SendLocalizationIds.Success.description,
                        asset.name
                    ),
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .image(localImage.name, localImage.bundle),
                            sideViewAttributes: .init(type: .image("v-success-icon"), position: .radiusDistanceFromCenter),
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    effects: .close,
                    buttonViewModel: .primary(with: SendLocalizationIds.Success.action)
                )
            case .swap:
                return .init(
                    title: SwapLocalizationIds.Success.title,
                    subtitle: String(
                        format: SwapLocalizationIds.Success.description,
                        asset.name
                    ),
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .templateImage(name: "swap-icon", bundle: .platformUIKit, templateColor: .white),
                            sideViewAttributes: .init(type: .image("v-success-icon"), position: .radiusDistanceFromCenter),
                            backgroundColor: .primaryButton,
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    effects: .close,
                    buttonViewModel: .primary(with: SwapLocalizationIds.Success.action)
                )
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                fatalError("Copy not supported for AssetAction: \(action)")
            }
        }

        static func failed(transactionState: TransactionState, action: AssetAction) -> State {
            let amount = transactionState.amount
            let errorTitle = transactionState.errorState.localizedDescription(
                transactionState: transactionState,
                action: action
            )
            switch action {
            case .send:
                let localImage = amount.currency.logoResource.local
                return .init(
                    title: errorTitle,
                    subtitle: SendLocalizationIds.Failure.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .image(localImage.name, localImage.bundle),
                            sideViewAttributes: .init(type: .image("circular-error-icon"), position: .radiusDistanceFromCenter),
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    effects: .close,
                    buttonViewModel: .primary(with: SendLocalizationIds.Failure.action)
                )
            case .swap:
                return .init(
                    title: errorTitle,
                    subtitle: SwapLocalizationIds.Failure.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .templateImage(name: "swap-icon", bundle: .platformUIKit, templateColor: .white),
                            sideViewAttributes: .init(type: .image("circular-error-icon"), position: .radiusDistanceFromCenter),
                            backgroundColor: .primaryButton,
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    effects: .close,
                    buttonViewModel: .primary(with: SwapLocalizationIds.Failure.action)
                )
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                fatalError("Copy not supported for AssetAction: \(action)")
            }
        }

        static func pending(action: AssetAction,
                            sent: MoneyValue,
                            received: MoneyValue?) -> State {
            switch action {
            case .send:
                var title = String(
                    format: SendLocalizationIds.Pending.title,
                    sent.displayString
                )
                let zeroSent = MoneyValue.zero(currency: sent.currencyType)
                if sent == zeroSent {
                    title = String(
                        format: SendLocalizationIds.Pending.title,
                        sent.displayCode
                    )
                }
                let localImage = sent.currency.logoResource.local
                return .init(
                    title: title,
                    subtitle: SendLocalizationIds.Pending.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .image(localImage.name, localImage.bundle),
                            sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    buttonViewModel: nil
                )
            case .swap:
                guard let received = received else {
                    fatalError("Expected Valid Inputs. 'received' is nil.")
                }
                let title: String
                if !received.isZero, !sent.isZero {
                    // If we have both sent and receive values:
                    title = String(
                        format: SwapLocalizationIds.Pending.title,
                        sent.displayString,
                        received.displayString
                    )
                } else if crashOnError {
                    // If we have invalid inputs and we should crash:
                    fatalError("Expected Valid Inputs. 'received': \(String(describing: received)). 'sent': \(sent)")
                } else {
                    // If we have invalid inputs but we should continue.
                    title = String(
                        format: SwapLocalizationIds.Pending.title,
                        sent.displayCode,
                        received.displayCode
                    )
                }
                return .init(
                    title: title,
                    subtitle: SwapLocalizationIds.Pending.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .templateImage(name: "swap-icon", bundle: .platformUIKit, templateColor: .white),
                            sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                            backgroundColor: .primaryButton,
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    buttonViewModel: nil
                )
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                fatalError("Copy not supported for AssetAction: \(action)")
            }
        }
    }
}

extension PendingTransactionPageInteractor {
    enum Effects {
        case close
        case none
    }
}

private extension TransactionErrorState {
    func localizedDescription(transactionState: TransactionState, action: AssetAction) -> String {
        switch self {
        case .none:
            return LocalizationConstants.Transaction.Error.generic
        case .addressIsContract:
            return LocalizationConstants.Transaction.Error.addressIsContract
        case .belowMinimumLimit:
            return minimumLimitErrorProvider(state: transactionState)
        case .insufficientFunds:
            return LocalizationConstants.Transaction.Error.insufficientFunds
        case .insufficientGas:
            return LocalizationConstants.Transaction.Error.insufficientGas
        case .insufficientFundsForFees:
            switch action {
            case .send:
                return LocalizationConstants.Transaction.Send.Completion.Failure.insufficientFundsForFees
            case .swap:
                return LocalizationConstants.Transaction.Swap.Completion.Failure.insufficientFundsForFees
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                Swift.fatalError("Copy not supported for AssetAction: \(action)")
            }
        case .invalidAddress:
            return LocalizationConstants.Transaction.Error.invalidAddress
        case .invalidAmount:
            return LocalizationConstants.Transaction.Error.invalidAmount
        case .invalidPassword:
            return LocalizationConstants.Transaction.Error.invalidPassword
        case .optionInvalid:
            return LocalizationConstants.Transaction.Error.optionInvalid
        case .overGoldTierLimit:
            return overGoldTierLimitProvider(state: transactionState)
        case .overMaximumLimit:
            return LocalizationConstants.Transaction.Error.overMaximumLimit
        case .overSilverTierLimit:
            return overSilverTierLimitProvider(state: transactionState)
        case .pendingOrdersLimitReached:
            return LocalizationConstants.Transaction.Error.pendingOrderLimitReached
        case .transactionInFlight:
            return LocalizationConstants.Transaction.Error.transactionInFlight
        case .unknownError:
            return LocalizationConstants.Transaction.Error.generic
        case .fatalError(let error):
            return String(describing: error)
        case .nabuError(let error):
            return String(describing: error)
        }
    }

    private func minimumLimitErrorProvider(state: TransactionState) -> String {
        guard let value = state.pendingTransaction?.minimumLimit else {
            return LocalizationConstants.Transaction.Error.underMinLimitGeneric
        }
        switch state.action {
        case .swap:
            return String(
                format: LocalizationConstants.Transaction.Swap.Completion.Failure.underMinLimit,
                value.toDisplayString(includeSymbol: true)
            )
        case .send:
            return String(
                format: LocalizationConstants.Transaction.Send.Completion.Failure.underMinLimit,
                value.toDisplayString(includeSymbol: true)
            )
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            return ""
        }
    }

    private func overGoldTierLimitProvider(state: TransactionState) -> String {
        guard let value = state.pendingTransaction?.maximumLimit else {
            return LocalizationConstants.Transaction.Error.generic
        }
        switch state.action {
        case .swap:
            return String(
                format: LocalizationConstants.Transaction.Swap.Completion.Failure.overGoldTierLimit,
                value.toDisplayString(includeSymbol: true)
            )
        case .send:
            return String(
                format: LocalizationConstants.Transaction.Send.Completion.Failure.overGoldTierLimit,
                value.toDisplayString(includeSymbol: true)
            )
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            return ""
        }
    }

    private func overSilverTierLimitProvider(state: TransactionState) -> String {
        switch state.action {
        case .swap:
            return LocalizationConstants.Transaction.Swap.Completion.Failure.overGoldTierLimit
        case .send:
            return LocalizationConstants.Transaction.Send.Completion.Failure.overGoldTierLimit
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            return ""
        }
    }
}
