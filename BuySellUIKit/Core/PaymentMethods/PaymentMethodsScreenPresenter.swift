//
//  PaymentMethodsScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class PaymentMethodsScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.PaymentMethodSelectionScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.PaymentMethodsScreen
    
    enum CellViewModelType {
        case suggestedPaymentMethod(ExplainedActionViewModel)
        case linkedCard(LinkedCardCellPresenter)
        case account(FiatCustodialBalanceViewPresenter)
    }
    
    // MARK: - Exposed
    
    let title = LocalizedString.title

    var cellViewModelTypes: Driver<[CellViewModelType]> {
        cellViewModelTypesRelay.asDriver()
    }
    
    // MARK: - Injected
    
    private(set) var cellViewModelTypesRelay = BehaviorRelay<[CellViewModelType]>(value: [])

    private let loadingViewPresenter: LoadingViewPresenting
    private let stateService: PaymentMethodsStateAPI
    private let interactor: PaymentMethodsScreenInteractor
    private let eventRecorder: AnalyticsEventRecording

    // MARK: - Accessories
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: PaymentMethodsScreenInteractor,
         loadingViewPresenter: LoadingViewPresenting = UIUtilityProvider.default.loader,
         stateService: PaymentMethodsStateAPI,
         eventRecorder: AnalyticsEventRecording) {
        self.loadingViewPresenter = loadingViewPresenter
        self.stateService = stateService
        self.interactor = interactor
        self.eventRecorder = eventRecorder
        
        interactor.methods
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .map { (methods: [PaymentMethodType]) -> [CellViewModelType] in
                methods
                    .compactMap { [weak self] type in
                        self?.generateCellType(by: type) ?? nil
                    }
            }
            .subscribe(
                onSuccess: { [weak cellViewModelTypesRelay] viewModelTypes in
                    cellViewModelTypesRelay?.accept(viewModelTypes)
                }
            )
            .disposed(by: disposeBag)
    }
        
    func viewWillAppear() {
        eventRecorder.record(event: AnalyticsEvent.sbPaymentMethodShown)
    }
    
    // MARK: - Navigation
    
    func previous() {
        stateService.previousRelay.accept(())
    }
    
    // MARK: - Private
    
    private func generateCellType(by paymentMethodType: PaymentMethodType) -> CellViewModelType? {
        let cellType: CellViewModelType
        switch paymentMethodType {
        case .suggested(let method):
            let viewModel: ExplainedActionViewModel
            switch method.type {
            case .funds:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "icon-deposit-cash",
                    title: LocalizedString.DepositCash.title,
                    descriptions: [LocalizedString.DepositCash.description],
                    badgeTitle: nil,
                    uniqueAccessibilityIdentifier: AccessibilityId.depositCash
                )
            case .card:
                viewModel = ExplainedActionViewModel(
                    thumbImage: "Icon-Creditcard",
                    title: LocalizedString.Card.title,
                    descriptions: [
                        "\(method.max.displayString) \(LocalizedString.Card.descriptionLimit)",
                        LocalizedString.Card.descriptionInfo
                    ],
                    badgeTitle: LocalizedString.Card.badgeTitle,
                    uniqueAccessibilityIdentifier: AccessibilityId.addCard
                )
            case .bankTransfer:
                fatalError("Bank transfer is not a valid payment method any longer")
            }
            viewModel.tap
                .emit(weak: self) { (self) in
                    let event: AnalyticsEvents.SimpleBuy.PaymentMethod
                    switch method.type {
                    case .bankTransfer:
                        event = .bank
                        self.interactor.select(method: paymentMethodType)
                        self.stateService.previousRelay.accept(())
                    case .funds(.fiat(let currency)):
                        event = .funds
                        self.showFundsTransferDetailsIfNeeded(for: currency)
                    case .funds(.crypto):
                        fatalError("Funds with crypto currency is not a possible state")
                    case .card:
                        event = .newCard
                        self.interactor.select(method: paymentMethodType)
                        self.stateService.previousRelay.accept(())
                    }
                    self.eventRecorder.record(
                        event: AnalyticsEvent.sbPaymentMethodSelected(selection: event)
                    )
                }
                .disposed(by: disposeBag)

            cellType = .suggestedPaymentMethod(viewModel)
        case .card(let cardData):
            let presenter = LinkedCardCellPresenter(
                acceptsUserInteraction: true,
                cardData: cardData
            )
            presenter.tap
                .emit(weak: self) { (self) in
                    self.eventRecorder.record(
                        event: AnalyticsEvent.sbPaymentMethodSelected(selection: .card)
                    )
                    self.interactor.select(method: paymentMethodType)
                    self.stateService.previousRelay.accept(())
                }
                .disposed(by: disposeBag)
            cellType = .linkedCard(presenter)
        case .account(let data):
            let presenter = FiatCustodialBalanceViewPresenter(
                interactor: interactor.custodialFiatBalanceViewInteractor(by: data.balance),
                descriptors: .paymentMethods(),
                respondsToTaps: true,
                presentationStyle: .plain
            )
            presenter.tap
                .emit(weak: self) { (self) in
                    self.eventRecorder.record(
                        event: AnalyticsEvent.sbPaymentMethodSelected(selection: .funds)
                    )
                    self.interactor.select(method: paymentMethodType)
                    self.stateService.previousRelay.accept(())
                }
                .disposed(by: disposeBag)
            cellType = .account(presenter)
        }
        
        return cellType
    }
    
    private func showFundsTransferDetailsIfNeeded(for currency: FiatCurrency) {
        interactor.isUserEligibleForFunds
            .handleLoaderForLifecycle(loader: loadingViewPresenter)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] isEligibile in
                if isEligibile {
                    self?.stateService.showFundsTransferDetails(for: currency, isOriginDeposit: false)
                } else {
                    self?.stateService.kyc()
                }
                
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: disposeBag)
        
    }
}
