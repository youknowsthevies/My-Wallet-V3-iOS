//
//  BuyCryptoScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit
import ToolKit

final class BuyCryptoScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen
    
    // MARK: - Properties
    
    /// TODO: We may want to move `deviceType` into a device designated presenter
    let deviceType = UIDevice.current.type
    
    let title = LocalizedString.title
    
    let selectionButtonViewModel: SelectionButtonViewModel
    let amountLabelViewModel: AmountLabelViewModel
    let correctionLinkViewModel: LinkViewModel
    let continueButtonViewModel: ButtonViewModel
    let separatorColor: Color = .lightBorder
    let digitPadViewModel: DigitPadViewModel
    var labeledButtonViewModels: Driver<[CurrencyLabeledButtonViewModel]> {
        return labeledButtonViewModelsRelay.asDriver()
    }
    
    private let labeledButtonViewModelsRelay = BehaviorRelay<[CurrencyLabeledButtonViewModel]>(value: [])
    
    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    private let interactor: BuyCryptoScreenInteractor
    private unowned let stateService: SimpleBuyCheckoutServiceAPI
    private unowned let router: SimpleBuyRouterAPI
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    /// TODO: Remove router dependency once the selection screen generics is simplified
    init(loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         alertPresenter: AlertViewPresenter = .shared,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         router: SimpleBuyRouterAPI,
         stateService: SimpleBuyCheckoutServiceAPI,
         interactor: BuyCryptoScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.loadingViewPresenter = loadingViewPresenter
        self.alertPresenter = alertPresenter
        self.router = router
        self.stateService = stateService
        self.interactor = interactor
        let fiatCurrencyService = interactor.fiatCurrencyService

        /// Digit Pad Setup
        
        let buttonHighlightColor = Color.black.withAlphaComponent(0.08)
        
        let customButtonViewModel = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: buttonHighlightColor)
        )
        digitPadViewModel = DigitPadViewModel(
            padType: .number,
            customButtonViewModel: customButtonViewModel,
            contentTint: .titleText,
            buttonHighlightColor: buttonHighlightColor
        )
        
        // Observe tapped digits
        digitPadViewModel.valueObservable
            .filter { !$0.isEmpty }
            .map { Character($0) }
            .map { .insert($0) }
            .bind(to: interactor.inputScanner.actionRelay)
            .disposed(by: disposeBag)
        
        // Observe backspace button taps
        digitPadViewModel.backspaceButtonTapObservable
            .map { .remove }
            .bind(to: interactor.inputScanner.actionRelay)
            .disposed(by: disposeBag)
        
        /// Continue Button Setup
        
        continueButtonViewModel = .primary(
            with: LocalizedString.ctaButton
        )
                
        interactor.state
            .map { $0.isValid }
            .bind(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
                
        // Amount Setup
        
        amountLabelViewModel = AmountLabelViewModel(
            fiatCurrencyService: fiatCurrencyService
        )
        interactor.inputScanner.input
            .bind(to: amountLabelViewModel.inputRelay)
            .disposed(by: disposeBag)
        
        // Asset Selection Button Setup
        
        selectionButtonViewModel = SelectionButtonViewModel()
        
        /// Labeled Views Setup
        
        interactor.suggestedAmounts
            .map { amounts in
                amounts
                    .enumerated()
                    .map {
                        .init(
                            amount: $0.element,
                            accessibilityId: "\($0.offset)"
                        )
                }
            }
            .bind(to: labeledButtonViewModelsRelay)
            .disposed(by: disposeBag)
        
        /// Limit View
        
        correctionLinkViewModel = LinkViewModel()
        interactor.state
            .map { state -> LinkViewModel.Text in
                switch state {
                case .empty:
                    return .empty
                case .inBounds(data: _, upperLimit: let value):
                    return .init(
                        prefix: String(
                            format: LocalizedString.LimitView.upperLimit,
                            value.toDisplayString()
                        ),
                        button: ""
                    )
                case .tooLow:
                    return .init(
                        prefix: LocalizedString.LimitView.Min.prefix,
                        button: LocalizedString.LimitView.Min.suffix
                    )
                case .tooHigh:
                    return .init(
                        prefix: LocalizedString.LimitView.Max.prefix,
                        button: LocalizedString.LimitView.Max.suffix
                    )
                }
            }
            .bind(to: correctionLinkViewModel.textRelay)
            .disposed(by: disposeBag)
        
        correctionLinkViewModel.tap
            .withLatestFrom(interactor.state)
            .compactMap { state -> FiatValue? in
                switch state {
                case .tooHigh(max: let amount), .tooLow(min: let amount):
                    return amount
                default:
                    return nil
                }
            }
            .map { $0.amount }
            .map { MoneyValueInputScanner.Input(decimal: $0) }
            .bind(to: interactor.inputScanner.inputRelay)
            .disposed(by: disposeBag)
        
        correctionLinkViewModel.tap
            .withLatestFrom(interactor.state)
            .compactMap { state in
                switch state {
                case .tooHigh:
                    return AnalyticsEvent.sbBuyFormMaxClicked
                case .tooLow:
                    return AnalyticsEvent.sbBuyFormMinClicked
                default:
                    return nil
                }
            }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        /// Additional binding
        
        struct CTAData {
            let kycState: BuyCryptoScreenInteractor.KYCState
            let checkoutData: SimpleBuyCheckoutData
        }
        
        let ctaObservable = continueButtonViewModel.tapRelay
            .withLatestFrom(interactor.data)
            .compactMap { $0 }
            .flatMap(weak: interactor) { (interactor, data) in
                interactor.currentKycState
                    .asObservable()
                    .map { result -> Result<CTAData, Error> in
                        switch result {
                        case .success(let state):
                            let ctaData = CTAData(kycState: state, checkoutData: data)
                            return .success(ctaData)
                        case .failure(let error):
                            return .failure(error)
                        }
                }
        }
        
        ctaObservable
            .compactMap { result -> SimpleBuyCheckoutData? in
                guard case let .success(state) = result else { return nil }
                return state.checkoutData
            }
            .map {
                AnalyticsEvent.sbBuyFormConfirmClick(
                    currencyCode: $0.fiatValue.currencyCode,
                    amount: $0.fiatValue.toDisplayString()
                )
            }
            .bind(to: analyticsRecorder.recordRelay)
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
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        ctaObservable
            .observeOn(MainScheduler.instance)
            .bind(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    switch data.kycState {
                    case .completed:
                        self.stateService.checkout(with: data.checkoutData)
                    case .shouldComplete:
                        self.stateService.kyc(with: data.checkoutData)
                    }
                case .failure:
                    self.handleError()
                }
            }
            .disposed(by: disposeBag)
        
        interactor.selectedCryptoCurrency
            .bind(weak: self) { (self, cryptoCurrency) in
                self.didSelect(cryptoCurrency: cryptoCurrency)
            }
            .disposed(by: disposeBag)
        
        interactor.selectedCryptoCurrency
            .map { AnalyticsEvent.sbBuyFormCryptoChanged(asset: $0) }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        interactor.pairsCalculationState
            .handle(loadingViewPresenter: loadingViewPresenter)
            .bind(weak: self) { (self, state) in
                guard case .invalid(.valueCouldNotBeCalculated) = state else {
                    return
                }
                self.handleError()
            }
            .disposed(by: disposeBag)
        
        interactor.state
            .map { state -> AmountLabelViewModel.State in
                switch state {
                case .inBounds, .empty:
                    return .valid
                case .tooLow, .tooHigh:
                    return .invalid
                }
            }
            .bind(to: amountLabelViewModel.stateRelay)
            .disposed(by: disposeBag)

        selectionButtonViewModel.tap
            .emit(onNext: { [unowned self] in
                self.router.showCryptoSelectionScreen()
            })
            .disposed(by: disposeBag)
        
        /// Observe labeled button view model changes and
        /// bind taps
        labeledButtonViewModelsRelay
            .map { viewModels in
                viewModels.map { $0.elementOnTap }
            }
            .bind(weak: self) { (self, amounts) in
                amounts.forEach { amount in
                    amount
                        .map { MoneyValueInputScanner.Input(decimal: $0) }
                        .emit(to: interactor.inputScanner.inputRelay)
                        .disposed(by: self.disposeBag)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Exposed methods
    
    func refresh() {
        interactor.refresh()
        analyticsRecorder.record(event: AnalyticsEvent.sbBuyFormShown)
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
    
    // MARK: - Private methods
    
    private func didSelect(cryptoCurrency: CryptoCurrency) {
        selectionButtonViewModel.set(
            imageName: cryptoCurrency.logoImageName,
            title: cryptoCurrency.name,
            accessibilityLabel: cryptoCurrency.code
        )
    }
    
    private func handleError() {
        analyticsRecorder.record(event: AnalyticsEvent.sbBuyFormConfirmFailure)
        alertPresenter.standardNotify(
            message: LocalizationConstants.SimpleBuy.ErrorAlert.message,
            title: LocalizationConstants.SimpleBuy.ErrorAlert.title
        )
    }
}
