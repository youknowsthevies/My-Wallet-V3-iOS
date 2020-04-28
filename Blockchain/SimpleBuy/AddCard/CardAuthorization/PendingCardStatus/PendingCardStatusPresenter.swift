//
//  CardAuthorizationScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit

final class PendingCardStatusPresenter: PendingStatePresenterAPI {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.PendingCardStatusScreen
    
    // MARK: - Properties
    
    var viewModel: Driver<PendingStateViewModel> {
        viewModelRelay
            .asDriver()
            .compactMap { $0 }
    }
     
    private let viewModelRelay = BehaviorRelay<PendingStateViewModel?>(value: nil)
    private let stateService: AddCardStateService
    private let interactor: PendingCardStatusInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(stateService: AddCardStateService,
         interactor: PendingCardStatusInteractor) {
        self.stateService = stateService
        self.interactor = interactor
        viewModelRelay.accept(
            PendingStateViewModel(
                asset: .loading,
                title: LocalizedString.LoadingScreen.title,
                subtitle: LocalizedString.LoadingScreen.subtitle
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
                    self?.handle(state: .inactive)
                }
            )
            .disposed(by: disposeBag)
    }
        
    private func handle(state: PendingCardStatusInteractor.State) {
        switch state {
        case .active(let cardData):
            self.stateService.end(with: cardData)
        case .inactive:
            let button = ButtonViewModel.primary(with: LocalizationConstants.ErrorScreen.button)
            button.tapRelay
                .bind(weak: self) { (self) in
                    self.stateService.dismiss()
                }
                .disposed(by: disposeBag)
            let viewModel = PendingStateViewModel(
                asset: .image(.circleError),
                title: LocalizationConstants.ErrorScreen.title,
                subtitle: LocalizationConstants.ErrorScreen.subtitle,
                button: button
            )
            viewModelRelay.accept(viewModel)
        case .timeout:
            let button = ButtonViewModel.primary(with: LocalizationConstants.ErrorScreen.button)
            button.tapRelay
                .bind(weak: self) { (self) in
                    self.stateService.dismiss()
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
    }
}
