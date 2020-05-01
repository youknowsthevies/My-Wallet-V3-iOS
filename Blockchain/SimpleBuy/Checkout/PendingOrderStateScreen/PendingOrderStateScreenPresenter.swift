//
//  TransferStateScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

final class PendingOrderStateScreenPresenter: PendingStatePresenterAPI {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.PendingOrderScreen
    
    // MARK: - Properties
        
    var viewModel: Driver<PendingStateViewModel> {
        viewModelRelay
            .asDriver()
            .compactMap { $0 }
    }
     
    private let viewModelRelay = BehaviorRelay<PendingStateViewModel?>(value: nil)
    private let stateService: PendingOrderCompletionStateServiceAPI
    private let interactor: PendingOrderStateScreenInteractor
    private let analyticsRecorder: AnalyticsEventRecording
    private let disposeBag = DisposeBag()
    
    private var amount: String {
        interactor.amount.toDisplayString(includeSymbol: true)
    }
    
    private var cryptoCurrency: CryptoCurrency {
        interactor.amount.currencyType
    }
    
    // MARK: - Setup
    
    init(stateService: PendingOrderCompletionStateServiceAPI,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         interactor: PendingOrderStateScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.interactor = interactor
        viewModelRelay.accept(
            PendingStateViewModel(
                compositeStatusViewType: .overlay(
                    baseImageName: PendingStateViewModel.Image.cutsom(cryptoCurrency.logoImageName).name,
                    rightViewType: .loader
                ),
                title: "\(LocalizedString.Loading.titlePrefix) \(amount)",
                subtitle: LocalizedString.Loading.subtitle
            )
        )
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
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
            .bind(weak: self) { (self) in
                self.stateService.orderCompleted()
            }
            .disposed(by: disposeBag)
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .overlay(
                baseImageName: PendingStateViewModel.Image.cutsom(cryptoCurrency.logoImageName).name,
                rightViewType: .image(PendingStateViewModel.Image.circleError.name)
            ),
            title: LocalizationConstants.ErrorScreen.title,
            subtitle: LocalizationConstants.ErrorScreen.subtitle,
            button: button
        )
        viewModelRelay.accept(viewModel)
    }
    
    private func handleTimeout(order: SimpleBuyOrderDetails) {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .bind(weak: self) { (self) in
                self.stateService.orderPending(with: order)
            }
            .disposed(by: disposeBag)
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .overlay(
                baseImageName: PendingStateViewModel.Image.cutsom(cryptoCurrency.logoImageName).name,
                rightViewType: .image(PendingStateViewModel.Image.clock.name)
            ),
            title: "\(amount) \(LocalizedString.Timeout.titleSuffix)",
            subtitle: LocalizedString.Timeout.subtitle,
            button: button
        )
        viewModelRelay.accept(viewModel)
    }
    
    private func handleSuccess() {
        let button = ButtonViewModel.primary(with: LocalizedString.button)
        button.tapRelay
            .bind(weak: self) { (self) in
                self.stateService.orderCompleted()
            }
            .disposed(by: disposeBag)
        let viewModel = PendingStateViewModel(
            compositeStatusViewType: .overlay(
                baseImageName: PendingStateViewModel.Image.cutsom(cryptoCurrency.logoImageName).name,
                rightViewType: .image("v-success-icon")
            ),
            title: "\(amount) \(LocalizedString.Success.titleSuffix)",
            subtitle: "\(LocalizedString.Success.Subtitle.prefix) \(cryptoCurrency.name) \(LocalizedString.Success.Subtitle.suffix)",
            button: button
        )
        self.viewModelRelay.accept(viewModel)
    }
        
    private func handle(state: SimpleBuyPolledOrder) {
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
                stateService.orderPending(with: order)
            }
        case .timeout(let order):
            analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCheckoutCompleted(status: .timeout))
            handleTimeout(order: order)
        case .cancel:
            break
        }
    }
}
