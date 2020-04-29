//
//  TransferStateScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
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
    private let disposeBag = DisposeBag()
    
    private var amount: String {
        interactor.amount.toDisplayString(includeSymbol: true)
    }
    
    private var cryptoCurrencyName: String {
        interactor.amount.currencyType.name
    }
    
    // MARK: - Setup
    
    init(stateService: PendingOrderCompletionStateServiceAPI,
         interactor: PendingOrderStateScreenInteractor) {
        self.stateService = stateService
        self.interactor = interactor
        viewModelRelay.accept(
            PendingStateViewModel(
                asset: .loading,
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
            asset: .image(.circleError),
            title: LocalizationConstants.ErrorScreen.title,
            subtitle: LocalizationConstants.ErrorScreen.subtitle,
            button: button
        )
        viewModelRelay.accept(viewModel)
    }
        
    private func handle(state: SimpleBuyPolledOrder) {
        let success = { [weak self] in
            guard let self = self else { return }
            let button = ButtonViewModel.primary(with: LocalizedString.button)
            button.tapRelay
                .bind(weak: self) { (self) in
                    self.stateService.orderCompleted()
                }
                .disposed(by: self.disposeBag)
            let viewModel = PendingStateViewModel(
                asset: .image(.success),
                title: "\(self.amount) \(LocalizedString.Success.titleSuffix)",
                subtitle: "\(LocalizedString.Success.Subtitle.prefix) \(self.cryptoCurrencyName) \(LocalizedString.Success.Subtitle.suffix)",
                button: button
            )
            self.viewModelRelay.accept(viewModel)
        }
        
        switch state {
        case .final(let order):
            switch order.state {
            case .cancelled, .failed, .expired:
                showError()
            case .finished:
                success()
            case .pendingConfirmation, .pendingDeposit, .depositMatched, .pendingExecution:
                break // Not final states - do nothing
            }
        case .timeout, .cancel:
            showError()
        }
    }
}
