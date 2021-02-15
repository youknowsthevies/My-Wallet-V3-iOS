//
//  BuyCryptoScreenPresenter.swift
//  BuySellUIKit
//
//  Created by Daniel on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class BuyCryptoScreenPresenter: EnterAmountScreenPresenter {
    
    // MARK: - Properties
        
    private let stateService: CheckoutServiceAPI
    private let router: RouterAPI
    private let interactor: BuyCryptoScreenInteractor
    
    private let disposeBag = DisposeBag()
    
    init(router: RouterAPI,
         stateService: CheckoutServiceAPI,
         interactor: BuyCryptoScreenInteractor,
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        
        self.interactor = interactor
        self.stateService = stateService
        self.router = router
        super.init(
            analyticsRecorder: analyticsRecorder,
            inputTypeToggleVisibility: .hidden,
            backwardsNavigation: {
                stateService.previousRelay.accept(())
            },
            displayBundle: .buy,
            interactor: interactor
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor.effect
            .subscribe(onNext: { [weak self] effect in
                switch effect {
                case .failure:
                    self?.router.showFailureAlert()
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        topSelectionButtonViewModel.tap
            .emit(weak: self) { (self) in
                self.router.showCryptoSelectionScreen()
            }
            .disposed(by: disposeBag)
        
        // Payment Method Selection Button Setup
        
        Observable
            .combineLatest(
                interactor.preferredPaymentMethodType,
                interactor.paymentMethodTypes.map { $0.count }
            )
            .do(onError: { [weak self] _ in
                self?.router.showFailureAlert()
            })
            .catchError { _ -> Observable<(PaymentMethodType?, Int)> in
                .empty()
            }
            .bindAndCatch(weak: self) { (self, payload) in
                self.setup(preferredPaymentMethodType: payload.0, methodCount: payload.1)
            }
            .disposed(by: disposeBag)
        
        /// Additional binding
        
        struct CTAData {
            let kycState: KycState
            let isSimpleBuyEligible: Bool
            let candidateOrderDetails: CandidateOrderDetails
        }
        
        let ctaObservable = continueButtonTapped
            .asObservable()
            .withLatestFrom(interactor.candidateOrderDetails)
            .compactMap { $0 }
            .show(loader: loader, style: .circle)
            .flatMap(weak: interactor) { (interactor, candidateOrderDetails) in
                Observable
                    .zip(
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
            .do(onError: { [weak self] _ in
                self?.router.showFailureAlert()
            })
            .catchError { error -> Observable<Result<CTAData, Error>> in
                .just(.failure(error))
            }
            .share()
        
        ctaObservable
            .compactMap { result -> CandidateOrderDetails? in
                guard case let .success(data) = result else { return nil }
                return data.candidateOrderDetails
            }
            .map(weak: self) { (self, candidateOrderDetails) in
                let paymentMethod = candidateOrderDetails.paymentMethod?.method
                return self.displayBundle.events.confirmTapped(
                    candidateOrderDetails.fiatValue.currency,
                    candidateOrderDetails.fiatValue.moneyValue,
                    [AnalyticsEvents.SimpleBuy.ParameterName.paymentMethod : (paymentMethod?.analyticsParameter.string) ?? ""]
                )
            }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
            
        ctaObservable
            .map(weak: self) { (self, result) -> AnalyticsEvent in
                switch result {
                case .success:
                    return self.displayBundle.events.confirmSuccess
                case .failure:
                    return self.displayBundle.events.confirmFailure
                }
            }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        ctaObservable
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    switch (data.kycState, data.isSimpleBuyEligible) {
                    case (.completed, false):
                        self.loader.hide()
                        self.stateService.ineligible()
                    case (.completed, true):
                        self.createOrder(from: data.candidateOrderDetails) { [weak self] checkoutData in
                            self?.loader.hide()
                            self?.stateService.nextFromBuyCrypto(with: checkoutData)
                        }
                    case (.shouldComplete, _):
                        self.createOrder(from: data.candidateOrderDetails) { [weak self] checkoutData in
                            self?.loader.hide()
                            self?.stateService.kyc(with: checkoutData)
                        }
                    }
                case .failure:
                    self.handleError()
                }
            }
            .disposed(by: disposeBag)
        
        interactor.selectedCurrencyType
            .map { $0.cryptoCurrency! }
            .flatMap(weak: self) { (self, cryptoCurrency) -> Observable<String?> in
                self.subtitleForCryptoCurrencyPicker(cryptoCurrency: cryptoCurrency)
            }
            .do(onError: { [weak self] _ in
                self?.router.showFailureAlert()
            })
            .catchError { _ -> Observable<String?> in
                .just(nil)
            }
            .bindAndCatch(to: topSelectionButtonViewModel.subtitleRelay)
            .disposed(by: disposeBag)
        
        // Bind to the pairs the user is able to buy
        
        interactor.pairsCalculationState
            .handle(loadingViewPresenter: loader)
            .catchError { _ -> Observable<ValueCalculationState<SupportedPairs>> in
                .just(.invalid(ValueCalculationState<SupportedPairs>.CalculationError.valueCouldNotBeCalculated))
            }
            .bindAndCatch(weak: self) { (self, state) in
                guard case .invalid(.valueCouldNotBeCalculated) = state else {
                    return
                }
                self.handleError()
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
    
    private func subtitleForCryptoCurrencyPicker(cryptoCurrency: CryptoCurrency) -> Observable<String?> {
        guard deviceType != .superCompact else {
            return .just(nil)
        }
        return Observable
            .combineLatest(
                interactor.fiatCurrencyService.fiatCurrencyObservable,
                Observable.just(cryptoCurrency)
            )
            .flatMap(weak: self) { (self, currencies) -> Observable<(FiatValue, CryptoCurrency)> in
                let fiat = currencies.0
                let crypto = currencies.1
                return self.interactor.priceService.price(for: crypto, in: fiat)
                    .compactMap(\.moneyValue.fiatValue)
                    .map { (fiat: $0, crypto: crypto) }
                    .asObservable()
            }
            .map { payload -> String in
                let tuple: (fiat: FiatValue, crypto: CryptoCurrency) = payload
                return "1 \(tuple.crypto.displayCode) = \(tuple.fiat.displayString) \(tuple.fiat.currencyCode)"
            }
            .catchError { _ -> Observable<String?> in
                .just(nil)
            }
    }
    
    private func setup(preferredPaymentMethodType: PaymentMethodType?, methodCount: Int) {
        let viewModel = SelectionButtonViewModel(with: preferredPaymentMethodType)
        if deviceType == .superCompact {
            viewModel.subtitleRelay.accept(nil)
        }
        
        let trailingImageViewContent: ImageViewContent
        if methodCount > 1 {
            trailingImageViewContent = ImageViewContent(
                imageName: "icon-disclosure-down-small"
            )
            viewModel.isButtonEnabledRelay.accept(true)
        } else {
            trailingImageViewContent = .empty
            viewModel.isButtonEnabledRelay.accept(false)
        }
        
        viewModel.trailingContentRelay.accept(.image(trailingImageViewContent))

        viewModel.tap
            .emit(weak: self) { (self) in
                self.stateService.paymentMethods()
            }
            .disposed(by: disposeBag)
        
        bottomAuxiliaryViewModelStateRelay.accept(.selection(viewModel))
    }
}
