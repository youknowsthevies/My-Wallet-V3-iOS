//
//  CheckoutScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CheckoutScreenPresenter: DetailsScreenPresenterAPI {

    typealias StateService = ConfirmCheckoutServiceAPI &
                             TransferDetailsServiceAPI &
                             CancelTransferServiceAPI
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout

    // MARK: - Navigation Properties

    let reloadRelay: PublishRelay<Void> = .init()

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    // MARK: - Screen Properties

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let uiUtilityProvider: UIUtilityProviderAPI
    private let interactor: CheckoutScreenInteractor
    private unowned let stateService: StateService

    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let contentReducer: CheckoutScreenContentReducer

    // MARK: - Setup
    
    init(stateService: StateService,
         uiUtilityProvider: UIUtilityProviderAPI = UIUtilityProvider.default,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording,
         interactor: CheckoutScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.uiUtilityProvider = uiUtilityProvider
        self.interactor = interactor

        // MARK: Content Reducer

        contentReducer = CheckoutScreenContentReducer(data: interactor.checkoutData)

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Buttons Setup

        buttons = [
            contentReducer.continueButtonViewModel,
            contentReducer.cancelButtonViewModel
            ]
            .compactMap { $0 }

        contentReducer.continueButtonViewModel
            .tapRelay
            .show(loader: uiUtilityProvider.loader, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.continue()
                    .mapToResult()
            }
            .hide(loader: uiUtilityProvider.loader)
            .bindAndCatch(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    self.stateService.confirmCheckout(with: data.0, isOrderNew: data.1)
                case .failure:
                    self.uiUtilityProvider.alert.error(in: nil, action: nil)
                }
            }
            .disposed(by: disposeBag)
        
        contentReducer.continueButtonViewModel
            .tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutConfirm }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        contentReducer.cancelButtonViewModel?
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.cancel()
            }
            .disposed(by: disposeBag)

        contentReducer.cancelButtonViewModel?
            .tapRelay
            .map(weak: self) { (self, _) in
                if self.interactor.checkoutData.isPendingDepositBankWire {
                    return AnalyticsEvent.sbPendingModalCancelClick
                }
                return AnalyticsEvent.sbCheckoutCancel
            }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        contentReducer.transferDetailsButtonViewModel?
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.stateService.bankTransferDetails(with: self.interactor.checkoutData)
            }
            .disposed(by: disposeBag)
    }

    /// Should get called once, when the view has finished loading
    func viewDidLoad() {
        interactor.setup()
            .handleLoaderForLifecycle(loader: uiUtilityProvider.loader, style: .circle)
            .subscribe(
                onSuccess: { [weak self] data in
                    self?.contentReducer.setupDidSucceed(with: data)
                },
                onError: { [weak self] _ in
                    self?.setupDidFail()
                }
            )
            .disposed(by: disposeBag)
        
        analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutShown)
    }

    private func cancel() {
        if interactor.checkoutData.isPendingDepositBankWire {
            stateService.cancelTransfer(with: interactor.checkoutData)
        } else {
            interactor.cancelIfPossible()
                .handleLoaderForLifecycle(loader: uiUtilityProvider.loader, style: .circle)
                .subscribe(
                    onSuccess: { [weak self] wasCancelled in
                        guard let self = self else { return }
                        if wasCancelled {
                            self.analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutCancelGoBack)
                        }
                        self.stateService.previousRelay.accept(())
                    }
                )
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Navigation

    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction {
        .custom { [weak self] in
            self?.cancel()
        }
    }

    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction {
        .custom { [weak self] in
            self?.stateService.previousRelay.accept(())
        }
    }
    
    /// Is called as the interaction setup fails
    private func setupDidFail() {
        uiUtilityProvider.alert.error(in: nil) { [weak self] in
            self?.cancel()
        }
    }
}
