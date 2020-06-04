//
//  CheckoutScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CheckoutScreenPresenter: DetailsScreenPresenterAPI {
    typealias StateService = SimpleBuyConfirmCheckoutServiceAPI &
                             SimpleBuyTransferDetailsServiceAPI &
                             SimpleBuyCancelTransferServiceAPI
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias AccessibilityId = Accessibility.Identifier.LineItem

    // MARK: - Navigation Properties

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    var titleView: Screen.Style.TitleView {
        .text(value: contentReducer.title)
    }

    // MARK: - Screen Properties

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    private let interactor: CheckoutScreenInteractor
    private unowned let stateService: StateService

    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let contentReducer: CheckoutScreenContentReducer

    // MARK: - Setup
    
    init(stateService: StateService,
         alertPresenter: AlertViewPresenter = .shared,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         interactor: CheckoutScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.loadingViewPresenter = loadingViewPresenter
        self.alertPresenter = alertPresenter
        self.interactor = interactor

        // MARK: Content Reducer

        contentReducer = CheckoutScreenContentReducer(data: interactor.checkoutData)

        // MARK: Buttons Setup

        buttons = [
            contentReducer.continueButtonViewModel,
            contentReducer.cancelButtonViewModel
            ]
            .compactMap { $0 }

        contentReducer.continueButtonViewModel
            .tapRelay
            .show(loader: loadingViewPresenter, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.continue()
                    .mapToResult()
            }
            .hide(loader: loadingViewPresenter)
            .bind(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    self.stateService.confirmCheckout(with: data.0, isOrderNew: data.1)
                case .failure:
                    self.alertPresenter.error()
                }
            }
            .disposed(by: disposeBag)
        
        contentReducer.continueButtonViewModel
            .tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutConfirm }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        contentReducer.cancelButtonViewModel?
            .tapRelay
            .bind(weak: self) { (self) in
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
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        contentReducer.transferDetailsButtonViewModel?
            .tapRelay
            .bind(weak: self) { (self) in
                self.stateService.transferDetails(with: self.interactor.checkoutData)
            }
            .disposed(by: disposeBag)
    }

    /// Should get called once, when the view has finished loading
    func viewDidLoad() {
        interactor.setup()
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
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
                .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
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
        alertPresenter.error { [weak stateService] in
            stateService?.previousRelay.accept(())
        }
    }
}
