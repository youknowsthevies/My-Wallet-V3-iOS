//
//  PendingTransactionPageInteractor.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 11/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
    
    init(transactionModel: TransactionModel,
         presenter: PendingTransactionPagePresentable) {
        self.transactionModel = transactionModel
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        let sent = transactionModel
            .state
            .map { try $0.moneyValueFromSource() }
        
        let received = transactionModel
            .state
            .map { try $0.moneyValueFromDestination() }
        
        let destination = transactionModel
            .state
            .compactMap(\.destination)
            .compactMap { $0 as? SingleAccount }
        
        let executionStatus = transactionModel
            .state
            .map(\.executionStatus)
        
        let interactorState = Observable
            .combineLatest(sent, received, destination, executionStatus)
            .map { (values) -> State in
                let (sent, received, destination, status) = values
                switch status {
                case .completed:
                    return .complete(destination: destination)
                case .error:
                    return .failed
                case .inProgress, .notStarted:
                    return .pending(sent: sent, received: received)
                }
            }
            .asDriverCatchError()
        
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
    typealias LocalizationId = LocalizationConstants.Transaction.Swap.Completion
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
        
        static func complete(destination: SingleAccount) -> State {
            .init(
                title: LocalizationId.Success.title,
                subtitle: String(
                    format: LocalizationId.Success.description,
                    destination.currencyType.name
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
                buttonViewModel: .primary(with: LocalizationId.Success.action)
            )
        }
        
        static let failed: State = .init(
            title: LocalizationId.Failure.title,
            subtitle: LocalizationId.Failure.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .templateImage(name: "swap-icon", templateColor: .white),
                    sideViewAttributes: .init(type: .image("circular-error-icon"), position: .radiusDistanceFromCenter),
                    backgroundColor: .primaryButton,
                    cornerRadiusRatio: 0.5
                )
            ),
            effects: .close,
            buttonViewModel: .primary(with: LocalizationId.Failure.action)
        )
        
        static func pending(sent: MoneyValue, received: MoneyValue) -> State {
            .init(
                title: String(format: LocalizationId.Pending.title, sent.displayString, received.displayString),
                subtitle: LocalizationId.Pending.description,
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
        }
    }
}

extension PendingTransactionPageInteractor {
    enum Effects {
        case close
        case none
    }
}
