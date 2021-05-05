// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

enum AddNewPaymentMethodAction {
    case items([AddNewPaymentMethodCellSectionModel])
}

enum AddNewPaymentMethodEffects {
    case closeFlow
    case navigate(method: PaymentMethodType)
}

protocol AddNewPaymentMethodRouting: ViewableRouting {
}

protocol AddNewPaymentMethodPresentable: Presentable {
    func connect(action: Driver<AddNewPaymentMethodAction>) -> Driver<AddNewPaymentMethodEffects>
}

protocol AddNewPaymentMethodListener: class {
    func closeFlow()
    func navigate(with method: PaymentMethod.MethodType)
}

final class AddNewPaymentMethodInteractor: PresentableInteractor<AddNewPaymentMethodPresentable>,
                                           AddNewPaymentMethodInteractable {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.AddPaymentMethodSelectionScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.PaymentMethodsScreen

    // MARK: - Injected

    weak var router: AddNewPaymentMethodRouting?
    weak var listener: AddNewPaymentMethodListener?

    private let paymentMethodService: SelectPaymentMethodService
    private let loadingViewPresenter: LoadingViewPresenting
    private let eventRecorder: AnalyticsEventRecording

    private let selectionRelay = PublishRelay<PaymentMethodType>()

    init(presenter: AddNewPaymentMethodPresentable,
         paymentMethodService: SelectPaymentMethodService,
         loadingViewPresenter: LoadingViewPresenting = resolve(),
         eventRecorder: AnalyticsEventRecording = resolve()) {
        self.paymentMethodService = paymentMethodService
        self.loadingViewPresenter = loadingViewPresenter
        self.eventRecorder = eventRecorder
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let methods = paymentMethodService.suggestedMethods
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .map { [weak self] (methods: [PaymentMethodType]) -> [AddNewPaymentMethodCellViewModelItem] in
                guard let self = self else { return [] }
                return methods.compactMap { type in
                    self.generateCellType(by: type) ?? nil
                }
            }
            .map { [AddNewPaymentMethodCellSectionModel(items: $0)] }
            .map { AddNewPaymentMethodAction.items($0) }
            .asDriver(onErrorDriveWith: .empty())

        let selectedPaymentMethod = selectionRelay
            .share(replay: 1, scope: .whileConnected)

        selectedPaymentMethod
            .filter { paymentMethod in
                if case .funds(.fiat) = paymentMethod.method {
                    return false
                }
                return true
            }
            .subscribe { method in
                self.paymentMethodService.select(method: method)
            }
            .disposeOnDeactivate(interactor: self)

        selectedPaymentMethod
            .map(AddNewPaymentMethodEffects.navigate(method:))
            .asDriverCatchError()
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)

        presenter.connect(action: methods)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private func handle(effect: AddNewPaymentMethodEffects) {
        switch effect {
        case .closeFlow:
            listener?.closeFlow()
        case .navigate(let type):
            listener?.navigate(with: type.method)
        }
    }

    private func generateCellType(by paymentMethodType: PaymentMethodType) -> AddNewPaymentMethodCellViewModelItem? {
        var cellType: AddNewPaymentMethodCellViewModelItem?
        switch paymentMethodType {
        case .suggested(let method):
            let viewModel: ExplainedActionViewModel
            switch method.type {
            case .funds:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "icon-deposit-cash",
                    title: LocalizedString.DepositCash.title,
                    descriptions: [
                        .init(title: LocalizedString.DepositCash.description, titleColor: .titleText, titleFontSize: 14)
                    ],
                    badgeTitle: nil,
                    uniqueAccessibilityIdentifier: AccessibilityId.depositCash
                )
            case .card:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "Icon-Creditcard",
                    title: LocalizedString.Card.title,
                    descriptions: [
                        .init(title: LocalizedString.Card.descriptionLimit, titleColor: .titleText, titleFontSize: 14),
                        .init(title: LocalizedString.Card.descriptionInfo, titleColor: .descriptionText, titleFontSize: 12)
                    ],
                    badgeTitle: LocalizedString.Card.badgeTitle,
                    uniqueAccessibilityIdentifier: AccessibilityId.addCard
                )
            case .bankTransfer:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "icon-bank",
                    title: LocalizedString.LinkABank.title,
                    descriptions: [
                        .init(title: LocalizedString.LinkABank.descriptionLimit, titleColor: .titleText, titleFontSize: 14),
                        .init(title: LocalizedString.LinkABank.descriptionInfo, titleColor: .descriptionText, titleFontSize: 12)
                    ],
                    badgeTitle: nil,
                    uniqueAccessibilityIdentifier: AccessibilityId.linkedBank
                )
            case .bankAccount:
                fatalError("Bank account is not a valid payment method any longer")
            }
            viewModel.tap
                .do { [weak self] _ in
                    guard let self = self else { return }
                    let event: AnalyticsEvents.SimpleBuy.PaymentMethod
                    switch method.type {
                    case .bankAccount:
                        event = .bank
                    case .bankTransfer:
                        event = .bank
                    case .funds(.fiat):
                        event = .funds
                    case .funds(.crypto):
                        fatalError("Funds with crypto currency is not a possible state")
                    case .card:
                        event = .newCard
                    }
                    self.eventRecorder.record(
                        event: AnalyticsEvent.sbPaymentMethodSelected(selection: event)
                    )
                }
                .map { _ in paymentMethodType }
                .emit(to: selectionRelay)
                .disposeOnDeactivate(interactor: self)

            cellType = .suggestedPaymentMethod(viewModel)
        case .card,
             .account,
             .linkedBank:
            cellType = nil
        }
        return cellType
    }
}
