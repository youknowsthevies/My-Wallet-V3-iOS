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
    
    init(transactionModel: TransactionModel,
         presenter: PendingTransactionPagePresentable,
         analyticsHook: TransactionAnalyticsHook = resolve()) {
        self.transactionModel = transactionModel
        self.analyticsHook = analyticsHook
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        let sent = transactionModel
            .state
            .map { state -> MoneyValue in
                switch state.moneyValueFromSource() {
                case .success(let value):
                    return value
                case .failure(let error):
                    #if INTERNAL_BUILD
                    fatalError(error.localizedDescription)
                    #else
                    return .zero(currency: state.source!.currencyType)
                    #endif
                }
            }
        
        let received = transactionModel
            .state
            .map { state -> MoneyValue in
                switch state.moneyValueFromDestination() {
                case .success(let value):
                    return value
                case .failure(let error):
                    #if INTERNAL_BUILD
                    fatalError(error.localizedDescription)
                    #else
                    return .zero(currency: (state.destination as! CryptoTarget).asset.currency)
                    #endif
                }
            }
        
        let action = transactionModel
            .state
            .map(\.action)
        
        let destination = transactionModel
            .state
            .compactMap(\.destination)
        
        let executionStatus = transactionModel
            .state
            .map(\.executionStatus)
        
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
            .withLatestFrom(transactionModel.state) { ($0, $1) }
            .subscribe(onNext: { [weak self] (executionStatus, transcationState) in
                switch executionStatus {
                case .inProgress, .notStarted:
                    break
                case .error:
                    self?.analyticsHook.onTransactionFailure(with: transcationState)
                case .completed:
                    self?.analyticsHook.onTransactionSuccess(with: transcationState)
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
                guard let receivedAmount = received else {
                    fatalError("Expected an amount received.")
                }
                var title = String(
                    format: SwapLocalizationIds.Pending.title,
                    sent.displayString,
                    receivedAmount.displayString
                )
                let zeroSent = MoneyValue.zero(currency: sent.currencyType)
                let zeroReceived = MoneyValue.zero(currency: receivedAmount.currencyType)
                if sent == zeroSent || received == zeroReceived {
                    title = String(
                        format: SwapLocalizationIds.Pending.title,
                        sent.displayCode,
                        receivedAmount.displayCode
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
