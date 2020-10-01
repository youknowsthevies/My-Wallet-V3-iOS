//
//  SellCryptoScreenPresenter.swift
//  BuySellUIKit
//
//  Created by Daniel on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit
import RxSwift
import RxRelay
import RxCocoa

final class SellCryptoScreenPresenter: EnterAmountScreenPresenter {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.SellCryptoScreen
    
    // MARK: - Properties
    
    private let auxiliaryViewPresenter: SendAuxililaryViewPresenter
    private let interactor: SellCryptoScreenInteractor
    private let routerInteractor: SellRouterInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(uiUtilityProvider: UIUtilityProviderAPI = UIUtilityProvider.default,
         analyticsRecorder: AnalyticsEventRecorderAPI,
         interactor: SellCryptoScreenInteractor,
         routerInteractor: SellRouterInteractor,
         backwardsNavigation: @escaping () -> Void) {
        self.routerInteractor = routerInteractor
        self.interactor = interactor
        auxiliaryViewPresenter = SendAuxililaryViewPresenter(
            interactor: interactor.auxiliaryViewInteractor,
            availableBalanceTitle: LocalizedString.available,
            maxButtonTitle: LocalizedString.useMax,
            maxButtonVisibility: .visible
        )
        super.init(
            uiUtilityProvider: uiUtilityProvider,
            analyticsRecorder: analyticsRecorder,
            backwardsNavigation: backwardsNavigation,
            displayBundle: .sell(cryptoCurrency: interactor.data.source.currencyType.cryptoCurrency!),
            interactor: interactor
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topSelectionButtonViewModel.isButtonEnabledRelay.accept(false)
        topSelectionButtonViewModel.trailingImageViewContentRelay.accept(.empty)
        bottomAuxiliaryViewModelStateRelay.accept(.maxAvailable(auxiliaryViewPresenter))
        topSelectionButtonViewModel.titleRelay.accept(
            String(format: LocalizedString.from, interactor.data.source.currencyType.code)
        )
        topSelectionButtonViewModel.subtitleRelay.accept(
            String(format: LocalizedString.to, interactor.data.destination.currencyType.code)
        )
        
        struct CTAData {
            let kycState: KycState
            let isSimpleBuyEligible: Bool
            let candidateOrderDetails: CandidateOrderDetails
        }
        
        let ctaObservable = continueButtonTapped
            .asObservable()
            .withLatestFrom(interactor.candidateOrderDetails)
            .compactMap { $0 }
            .show(loader: uiUtilityProvider.loader, style: .circle)
            .flatMap(weak: interactor) { (interactor, candidateOrderDetails) -> Observable<Result<CTAData, Error>> in
                Observable.zip(
                    interactor.currentKycState.asObservable(),
                    interactor.currentEligibilityState
                )
                .map { (currentKycState, currentEligibilityState) -> Result<CTAData, Error> in
                    switch (currentKycState, currentEligibilityState) {
                    case (.success(let kycState), .success(let isSimpleBuyEligible)):
                        let ctaData = CTAData(
                            kycState: kycState,
                            isSimpleBuyEligible: isSimpleBuyEligible,
                            candidateOrderDetails: candidateOrderDetails
                        )
                        return .success(ctaData)
                    case (.failure(let error), .success):
                        return .failure(error)
                    case (.success, .failure(let error)):
                        return .failure(error)
                    case (.failure(let error), .failure):
                        return .failure(error)
                    }
                }
            }
            .share()
        
        ctaObservable
        .observeOn(MainScheduler.instance)
        .bindAndCatch(weak: self) { (self, result) in
            switch result {
            case .success(let data):
                switch (data.kycState, data.isSimpleBuyEligible) {
                case (.completed, false):
                    self.uiUtilityProvider.loader.hide()
                    // TODO: inelligible
                case (.completed, true):
                    self.createOrder(from: data.candidateOrderDetails) { [weak self] checkoutData in
                        self?.uiUtilityProvider.loader.hide()
                        self?.routerInteractor.nextFromSellCrypto(checkoutData: checkoutData)
                    }
                case (.shouldComplete, _):
                    self.createOrder(from: data.candidateOrderDetails) { [weak self] checkoutData in
                        self?.uiUtilityProvider.loader.hide()
                        // TODO: KYC with checkout data
                    }
                }
            case .failure(let error):
                self.handleError()
            }
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func createOrder(from candidateOrderDetails: CandidateOrderDetails,
                             with completion: @escaping (CheckoutData) -> Void) {
        
        interactor.createOrder(from: candidateOrderDetails)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: completion,
                onError: { [weak self] error in
                    self?.handleError()
                }
            )
            .disposed(by: disposeBag)
    }
}
