//
//  TransferStateScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class PendingOrderStateScreenPresenter: Presenter, PendingStatePresenterAPI {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.PendingOrderScreen
    
    // MARK: - Properties
        
    var viewModel: Driver<PendingStateViewModel> {
        viewModelRelay
            .asDriver()
            .compactMap { $0 }
    }
         
    private let viewModelRelay = BehaviorRelay<PendingStateViewModel?>(value: nil)
    private let routingInteractor: PendingOrderRoutingInteracting
    private let interactor: PendingOrderStateScreenInteractor
    private let analyticsRecorder: AnalyticsEventRecording
    private let disposeBag = DisposeBag()
    
    private var amount: String {
        interactor.amount.toDisplayString(includeSymbol: true)
    }
    
    private var currencyType: CurrencyType {
        interactor.amount.currencyType
    }
    
    // MARK: - Setup
    
    init(routingInteractor: PendingOrderRoutingInteracting,
         analyticsRecorder: AnalyticsEventRecording,
         interactor: PendingOrderStateScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.routingInteractor = routingInteractor
        self.interactor = interactor
        super.init(interactable: interactor)
    }
        
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let isBuy = interactor.isBuy
        let prefix = isBuy ? LocalizedString.Loading.Buy.titlePrefix : LocalizedString.Loading.Sell.titlePrefix
        let subtitle = isBuy ? LocalizedString.Loading.Buy.subtitle : LocalizedString.Loading.Sell.subtitle
        viewModelRelay.accept(
            PendingStateViewModel(
                compositeStatusViewType: .composite(
                    .init(
                        baseViewType: .image(PendingStateViewModel.Image.cutsom(currencyType.logoImageName).name),
                        sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter)
                    )
                ),
                title: "\(prefix) \(amount)",
                subtitle: subtitle
            )
        )
        
        interactor.startPolling()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] state in
                    self?.handle(state: state)
                },
                onError: { [weak self] error in
                    self?.showError()
                }
            )
            .disposed(by: disposeBag)
    }
        
    private func showError() {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .map { .completed }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)
        
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(PendingStateViewModel.Image.cutsom(currencyType.logoImageName).name),
                    sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.circleError.name), position: .radiusDistanceFromCenter)
                )
            ),
            title: LocalizationConstants.ErrorScreen.title,
            subtitle: LocalizationConstants.ErrorScreen.subtitle,
            button: button
        )
        viewModelRelay.accept(viewModel)
    }
    
    private func handleTimeout(order: OrderDetails) {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .map { .pending(order) }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)
        let title = interactor.isBuy ? LocalizedString.Timeout.Buy.titleSuffix : LocalizedString.Timeout.Sell.titleSuffix
        
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(PendingStateViewModel.Image.cutsom(currencyType.logoImageName).name),
                    sideViewAttributes: .init(type: .image(PendingStateViewModel.Image.clock.name), position: .radiusDistanceFromCenter)
                )
            ),
            title: "\(amount) \(title)",
            subtitle: LocalizedString.Timeout.subtitle,
            button: button
        )
        viewModelRelay.accept(viewModel)
    }
    
    private func handleSuccess() {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .map { .completed }
            .bindAndCatch(to: routingInteractor.stateRelay)
            .disposed(by: disposeBag)
        let suffix = interactor.isBuy ? LocalizedString.Success.Buy.titleSuffix : LocalizedString.Success.Sell.titleSuffix
        let name = interactor.isBuy ? currencyType.name : LocalizedString.Success.Sell.cash
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .composite(
                .init(
                    baseViewType: .image(PendingStateViewModel.Image.cutsom(currencyType.logoImageName).name),
                    sideViewAttributes: .init(type: .image("v-success-icon"), position: .radiusDistanceFromCenter)
                )
            ),
            title: "\(amount) \(suffix)",
            subtitle: "\(LocalizedString.Success.Subtitle.prefix) \(name) \(LocalizedString.Success.Subtitle.suffix)",
            button: button
        )
        self.viewModelRelay.accept(viewModel)
    }
        
    private func handle(state: PolledOrder) {
        switch state {
        case .final(let order):
            switch order.state {
            case .cancelled, .failed, .expired:
                analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .failure))
                showError()
            case .finished:
                analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .success))
                handleSuccess()
            case .pendingConfirmation, .pendingDeposit, .depositMatched:
                // This state is practically not possible by design since the app polls until
                // the order is in one of the final states (success / error).
                routingInteractor.stateRelay.accept(.pending(order))
            }
        case .timeout(let order):
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .timeout))
            handleTimeout(order: order)
        case .cancel:
            break
        }
    }
}
