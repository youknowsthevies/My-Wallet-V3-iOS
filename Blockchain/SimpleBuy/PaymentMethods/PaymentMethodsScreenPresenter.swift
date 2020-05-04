//
//  PaymentMethodsScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

final class PaymentMethodsScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.PaymentMethodSelectionScreen
        
    enum CellViewModelType {
        case suggestedPaymentMethod(SelectionButtonViewModel)
        case linkedCard(LinkedCardCellPresenter)
    }
    
    // MARK: - Exposed
    
    let title = LocalizedString.title

    var cellViewModelTypes: Driver<[CellViewModelType]> {
        cellViewModelTypesRelay.asDriver()
    }
    
    // MARK: - Injected
    
    private(set) var cellViewModelTypesRelay = BehaviorRelay<[CellViewModelType]>(value: [])

    private let loadingViewPresenter: LoadingViewPresenting
    private let stateService: RoutingPreviousStateEmitterAPI
    private let interactor: PaymentMethodsScreenInteractor
    private let eventRecorder: AnalyticsEventRecording

    // MARK: - Accessories
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: PaymentMethodsScreenInteractor,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         stateService: RoutingPreviousStateEmitterAPI,
         eventRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.loadingViewPresenter = loadingViewPresenter
        self.stateService = stateService
        self.interactor = interactor
        self.eventRecorder = eventRecorder
        
        interactor.methods
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .map { (methods: [SimpleBuyPaymentMethodType]) -> [CellViewModelType] in
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
    
    private func generateCellType(by paymentMethodType: SimpleBuyPaymentMethodType) -> CellViewModelType? {
        let cellType: CellViewModelType
        switch paymentMethodType {
        case .suggested(let method):
            let viewModel = SelectionButtonViewModel(with: paymentMethodType)
            viewModel.horizontalOffsetRelay.accept(24)
            viewModel.verticalOffsetRelay.accept(16)
            viewModel.tap
                .emit(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.eventRecorder.record(
                        event: AnalyticsEvent.sbPaymentMethodSelected(
                            selection: method.type == .bankTransfer ? .bank : .newCard
                        )
                    )
                    self.interactor.select(method: paymentMethodType)
                    self.stateService.previousRelay.accept(())
                })
                .disposed(by: disposeBag)
            cellType = .suggestedPaymentMethod(viewModel)
        case .card(let cardData):
            let presenter = LinkedCardCellPresenter(
                acceptsUserInteraction: true,
                cardData: cardData
            )
            presenter.tap
                .emit(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.eventRecorder.record(
                        event: AnalyticsEvent.sbPaymentMethodSelected(selection: .card)
                    )
                    self.interactor.select(method: paymentMethodType)
                    self.stateService.previousRelay.accept(())
                })
                .disposed(by: disposeBag)
            cellType = .linkedCard(presenter)
        }
        
        return cellType
    }
    
    func viewWillAppear() {
        eventRecorder.record(event: AnalyticsEvent.sbPaymentMethodShown)
    }
    
    // MARK: - Navigation
    
    func previous() {
        stateService.previousRelay.accept(())
    }
}
