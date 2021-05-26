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
                        fatalError(error.localizedDescription)
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
                        fatalError(error.localizedDescription)
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

        let action = transactionState.map(\.action)
        let destination = transactionState.compactMap(\.destination)
        let executionStatus = transactionState.map(\.executionStatus)

        let interactorState = Observable
            .combineLatest(sent, received, destination, executionStatus, action)
            .map { (values) -> State in
                let (sent, received, destination, status, action) = values
                switch status {
                case .completed:
                    return .complete(amount: sent, destination: destination, action: action)
                case .error:
                    return .failed(amount: sent, action: action)
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
                            baseViewType: .image(asset.logoImageName),
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
                            baseViewType: .templateImage(name: "swap-icon", templateColor: .white),
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

        static func failed(amount: MoneyValue, action: AssetAction) -> State {
            switch action {
            case .send:
                return .init(
                    title: SendLocalizationIds.Failure.title,
                    subtitle: SendLocalizationIds.Failure.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .image(amount.currency.logoImageName),
                            sideViewAttributes: .init(type: .image("circular-error-icon"), position: .radiusDistanceFromCenter),
                            cornerRadiusRatio: 0.5
                        )
                    ),
                    effects: .close,
                    buttonViewModel: .primary(with: SendLocalizationIds.Failure.action)
                )
            case .swap:
                return .init(
                    title: SwapLocalizationIds.Failure.title,
                    subtitle: SwapLocalizationIds.Failure.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .templateImage(name: "swap-icon", templateColor: .white),
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
                return .init(
                    title: title,
                    subtitle: SendLocalizationIds.Pending.description,
                    compositeViewType: .composite(
                        .init(
                            baseViewType: .image(sent.currency.logoImageName),
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
                            baseViewType: .templateImage(name: "swap-icon", templateColor: .white),
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
