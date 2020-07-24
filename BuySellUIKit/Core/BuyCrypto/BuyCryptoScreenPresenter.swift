//
//  BuyCryptoScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
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

final class BuyCryptoScreenPresenter {

    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.BuyScreen

    /// The state of the payment method selection button
    enum PaymentMethodSelectionButtonViewModelState {
        
        /// Visible
        case visible(SelectionButtonViewModel)
        
        /// Hidden (no payment methods available to the user)
        case hidden
    }
    
    // MARK: - Properties

    let deviceType = DevicePresenter.type

    let title = LocalizedString.title
    
    let amountTranslationPresenter: AmountTranslationPresenter
    let assetSelectionButtonViewModel: SelectionButtonViewModel
    let continueButtonViewModel: ButtonViewModel
    let separatorColor: Color = .lightBorder
    let paymentMethodSeparatorViewModel: TitledSeparatorViewModel
    let digitPadViewModel: DigitPadViewModel
    let currencySelectionRelay = PublishRelay<Void>()

    var paymentMethodSelectionButtonViewModelState: Driver<PaymentMethodSelectionButtonViewModelState> {
        paymentMethodSelectionButtonViewModelStateRelay.asDriver()
    }

    private let paymentMethodSelectionButtonViewModelStateRelay = BehaviorRelay(
        value: PaymentMethodSelectionButtonViewModelState.hidden
    )
    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let uiUtilityProvider: UIUtilityProviderAPI
    private let interactor: BuyCryptoScreenInteractor

    private unowned let stateService: CheckoutServiceAPI
    private unowned let router: RouterAPI
        
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(uiUtilityProvider: UIUtilityProviderAPI = UIUtilityProvider.default,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording,
         router: RouterAPI,
         stateService: CheckoutServiceAPI,
         interactor: BuyCryptoScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.uiUtilityProvider = uiUtilityProvider
        self.router = router
        self.stateService = stateService
        self.interactor = interactor

        paymentMethodSeparatorViewModel = TitledSeparatorViewModel(
            title: LocalizedString.paymentMethodTitle,
            accessibilityId: AccessibilityId.paymentMethodTitle
        )
        
        /// Amount translation
        amountTranslationPresenter = AmountTranslationPresenter(
            interactor: interactor.amountTranslationInteractor,
            analyticsRecorder: analyticsRecorder,
            minTappedAnalyticsEvent: AnalyticsEvents.SimpleBuy.sbBuyFormMinClicked,
            maxTappedAnalyticsEvent: AnalyticsEvents.SimpleBuy.sbBuyFormMaxClicked
        )
        // Hide swap button
        amountTranslationPresenter.swapButtonVisibilityRelay.accept(.hidden)
        
        /// Digit Pad Setup
        
        digitPadViewModel = BuyCryptoScreenPresenter.digitPadViewModel()
        digitPadViewModel.valueObservable
            .filter { !$0.isEmpty }
            .map { Character($0) }
            .bindAndCatch(to: interactor.amountTranslationInteractor.appendNewRelay)
            .disposed(by: disposeBag)
                
        digitPadViewModel.backspaceButtonTapObservable
            .bindAndCatch(to: interactor.amountTranslationInteractor.deleteLastRelay)
            .disposed(by: disposeBag)

        /// Continue Button Setup
        
        continueButtonViewModel = .primary(
            with: LocalizedString.ctaButton
        )
                
        interactor.state
            .map { $0.isValid }
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
                
        // Asset Selection Button Setup
        
        assetSelectionButtonViewModel = SelectionButtonViewModel(showSeparator: true)

        /// Additional binding
        
        struct CTAData {
            let kycState: KycState
            let isSimpleBuyEligible: Bool
            let candidateOrderDetails: CandidateOrderDetails
        }
        
        let ctaObservable = continueButtonViewModel.tapRelay
            .withLatestFrom(interactor.candidateOrderDetails)
            .compactMap { $0 }
            .show(loader: uiUtilityProvider.loader, style: .circle)
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
            .share()
        
        ctaObservable
            .compactMap { result -> CandidateOrderDetails? in
                guard case let .success(data) = result else { return nil }
                return data.candidateOrderDetails
            }
            .map {
                AnalyticsEvent.sbBuyFormConfirmClick(
                    currencyCode: $0.fiatValue.currencyCode,
                    amount: $0.fiatValue.toDisplayString(),
                    paymentMethod: $0.paymentMethod.method.analyticsParameter
                )
            }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
            
        ctaObservable
            .map { result -> AnalyticsEvent in
                switch result {
                case .success:
                    return .sbBuyFormConfirmSuccess
                case .failure:
                    return .sbBuyFormConfirmFailure
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
                        self.uiUtilityProvider.loader.hide()
                        self.stateService.ineligible()
                    case (.completed, true):
                        self.createOrder(from: data.candidateOrderDetails) { [weak self] checkoutData in
                            self?.uiUtilityProvider.loader.hide()
                            self?.stateService.nextFromBuyCrypto(with: checkoutData)
                        }
                    case (.shouldComplete, _):
                        self.createOrder(from: data.candidateOrderDetails) { [weak self] checkoutData in
                            self?.uiUtilityProvider.loader.hide()
                            self?.stateService.kyc(with: checkoutData)
                        }
                    }
                case .failure:
                    self.handleError()
                }
            }
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map {
                .image(
                    .init(
                        name: $0.logoImageName,
                        background: .clear,
                        offset: 0,
                        cornerRadius: .round,
                        size: .init(edge: 32)
                    )
                )
            }
            .bindAndCatch(to: assetSelectionButtonViewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map { $0.name }
            .bindAndCatch(to: assetSelectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map { .init(id: $0.displayCode, label: $0.name) }
            .bindAndCatch(to: assetSelectionButtonViewModel.accessibilityContentRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .flatMap(weak: self) { (self, cryptoCurrency) -> Observable<String?> in
                self.subtitleForCryptoCurrencyPicker(cryptoCurrency: cryptoCurrency)
            }
            .bindAndCatch(to: assetSelectionButtonViewModel.subtitleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map { AnalyticsEvent.sbBuyFormCryptoChanged(asset: $0) }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        interactor.pairsCalculationState
            .handle(loadingViewPresenter: uiUtilityProvider.loader)
            .bindAndCatch(weak: self) { (self, state) in
                guard case .invalid(.valueCouldNotBeCalculated) = state else {
                    return
                }
                self.handleError()
            }
            .disposed(by: disposeBag)
        
        assetSelectionButtonViewModel.trailingImageViewContentRelay.accept(
            ImageViewContent(
                imageName: "icon-disclosure-down-small"
            )
        )
        
        assetSelectionButtonViewModel.tap
            .emit(onNext: { [unowned self] in
                self.router.showCryptoSelectionScreen()
            })
            .disposed(by: disposeBag)
        
        // Payment Method Selection Button Setup
        
        Observable
            .combineLatest(
                interactor.preferredPaymentMethodType,
                interactor.paymentMethodTypes.map { $0.count }
            )
            .bindAndCatch(weak: self) { (self, payload) in
                self.setup(preferredPaymentMethodType: payload.0, methodCount: payload.1)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Exposed methods
    
    func refresh() {
        interactor.refresh()
        analyticsRecorder.record(event: AnalyticsEvent.sbBuyFormShown)
    }
    
    func previous() {
        stateService.previousRelay.accept(())
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
        
        viewModel.trailingImageViewContentRelay.accept(trailingImageViewContent)

        viewModel.tap
            .emit(onNext: { [weak stateService] in
                stateService?.paymentMethods()
            })
            .disposed(by: disposeBag)
        
        paymentMethodSelectionButtonViewModelStateRelay.accept(.visible(viewModel))
    }
    
    private func handleError() {
        analyticsRecorder.record(event: AnalyticsEvent.sbBuyFormConfirmFailure)
        uiUtilityProvider.loader.hide()
        uiUtilityProvider.alert.error(in: nil, action: nil)
    }

    func subtitleForCryptoCurrencyPicker(cryptoCurrency: CryptoCurrency) -> Observable<String?> {
        guard deviceType != .superCompact else {
            return .just(nil)
        }
        return Observable
            .combineLatest(
                interactor.exchangeProvider[cryptoCurrency].fiatPrice,
                Observable.just(cryptoCurrency)
            )
            .map { payload -> String in
                let tuple: (fiat: FiatValue, crypto: CryptoCurrency) = payload
                return "1 \(tuple.crypto.displayCode) = \(tuple.fiat.toDisplayString()) \(tuple.fiat.currencyCode)"
            }
    }

    private static func digitPadViewModel() -> DigitPadViewModel {
        let highlightColor = Color.black.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .titleText,
            buttonHighlightColor: highlightColor
        )
    }
}
