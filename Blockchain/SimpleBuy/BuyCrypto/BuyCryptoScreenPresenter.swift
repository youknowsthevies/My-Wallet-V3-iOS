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
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.BuyScreen
    
    // MARK: - Properties

    let deviceType = DevicePresenter.type

    let title = LocalizedString.title
    
    let selectionButtonViewModel: SelectionButtonViewModel
    let amountLabelViewModel: AmountLabelViewModel
    let continueButtonViewModel: ButtonViewModel
    let separatorColor: Color = .lightBorder
    let digitPadViewModel: DigitPadViewModel
    let currencySelectionRelay = PublishRelay<Void>()
    var labeledButtonViewModels: Driver<[CurrencyLabeledButtonViewModel]> {
        return labeledButtonViewModelsRelay.asDriver()
    }
    let trailingButtonViewModel: ButtonViewModel

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

        /// Trailing Button Setup
        trailingButtonViewModel = BuyCryptoScreenPresenter.trailingButtonViewModel()

        /// Digit Pad Setup
        digitPadViewModel = BuyCryptoScreenPresenter.digitPadViewModel()
        
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
            fiatCurrencyService: fiatCurrencyService,
            shouldDisplayStateImage: false
        )
        interactor.inputScanner.input
            .bind(to: amountLabelViewModel.inputRelay)
            .disposed(by: disposeBag)
        
        // Asset Selection Button Setup
        
        selectionButtonViewModel = SelectionButtonViewModel(showSeparator: true)

        /// Additional binding
        
        struct CTAData {
            let kycState: BuyCryptoScreenInteractor.KYCState
            let isSimpleBuyEligible: Bool
            let checkoutData: SimpleBuyCheckoutData
        }
        
        let ctaObservable = continueButtonViewModel.tapRelay
            .withLatestFrom(interactor.data)
            .compactMap { $0 }
            .flatMap(weak: interactor) { (interactor, data) in
                Observable.zip(
                    interactor.currentKycState.asObservable(),
                    interactor.currentEligibiltyState
                    )
                    .map { (currentKycState, currentEligibiltyState) -> Result<CTAData, Error> in
                        switch (currentKycState, currentEligibiltyState) {
                        case (.success(let kycState), .success(let isSimpleBuyEligible)):
                            let ctaData = CTAData(kycState: kycState, isSimpleBuyEligible: isSimpleBuyEligible, checkoutData: data)
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
                    switch (data.kycState, data.isSimpleBuyEligible) {
                    case (.completed, true):
                        self.stateService.checkout(with: data.checkoutData)
                    case (.completed, false):
                        self.stateService.ineligible(with: data.checkoutData)
                    case (.shouldComplete, _):
                        self.stateService.kyc(with: data.checkoutData)
                    }
                case .failure:
                    self.handleError()
                }
            }
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map { .image($0.logoImageName) }
            .bind(to: selectionButtonViewModel.leadingContentRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map { $0.name }
            .bind(to: selectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .map { $0.displayCode }
            .bind(to: selectionButtonViewModel.accessibilityLabelRelay)
            .disposed(by: disposeBag)

        interactor.selectedCryptoCurrency
            .flatMap(weak: self) { (self, cryptoCurrency) -> Observable<String?> in
                self.subtitleForCryptoCurrencyPicker(cryptoCurrency: cryptoCurrency)
            }
            .bind(to: selectionButtonViewModel.subtitleRelay)
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

        interactor
            .state
            .flatMap(weak: self) { (self, state) in
                self.labeledButtons(for: state)
            }
            .bind(to: labeledButtonViewModelsRelay)
            .disposed(by: disposeBag)

        labeledButtonViewModelsRelay
            .map { $0.map { $0.elementOnTap } }
            .bind(weak: self) { (self, amounts) in
                amounts.forEach { amount in
                    amount
                        .map { MoneyValueInputScanner.Input(decimal: $0) }
                        .emit(to: interactor.inputScanner.inputRelay)
                        .disposed(by: self.disposeBag)
                }
            }
            .disposed(by: disposeBag)

        interactor
            .state
            .map {
                switch $0 {
                case .tooHigh:
                    return LocalizedString.LimitView.Max.useMax
                case .tooLow:
                    return LocalizedString.LimitView.Min.useMin
                case .empty(currency: let currency):
                    return "\(currency.code)"
                case .inBounds(data: _, upperLimit: let fiatValue):
                    return "\(fiatValue.currencyCode)"
                }
            }
            .bind(to: trailingButtonViewModel.textRelay)
            .disposed(by: disposeBag)

        trailingButtonViewModel
            .tapRelay
            .withLatestFrom(interactor.state)
            .compactMap { state -> AnalyticsEvent? in
                switch state {
                case .tooHigh:
                    return .sbBuyFormMaxClicked
                case .tooLow:
                    return .sbBuyFormMinClicked
                case .empty, .inBounds:
                    return nil
                }
            }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        trailingButtonViewModel
            .tapRelay
            .withLatestFrom(interactor.state)
            .filter { ($0.isValid || $0.isEmpty) }
            .mapToVoid()
            .bind { stateService.changeCurrency() }
            .disposed(by: disposeBag)

        trailingButtonViewModel
            .tapRelay
            .withLatestFrom(interactor.state)
            .compactMap { state -> Decimal? in
                switch state {
                case .tooHigh(let fiat):
                    return fiat.amount
                case .tooLow(let fiat):
                    return fiat.amount
                case .empty, .inBounds:
                    return nil
                }
            }
            .map { MoneyValueInputScanner.Input(decimal: $0) }
            .bind(to: interactor.inputScanner.inputRelay)
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

    private func handleError() {
        analyticsRecorder.record(event: AnalyticsEvent.sbBuyFormConfirmFailure)
        alertPresenter.standardNotify(
            message: LocalizationConstants.SimpleBuy.ErrorAlert.message,
            title: LocalizationConstants.SimpleBuy.ErrorAlert.title
        )
    }

    func subtitleForCryptoCurrencyPicker(cryptoCurrency: CryptoCurrency) -> Observable<String?> {
        guard deviceType != .superCompact else {
            return .just(nil)
        }
        return Observable
            .zip(
                interactor.exchangeProviding[cryptoCurrency].fiatPrice.share(replay: 1),
                Observable.just(cryptoCurrency)
            )
            .map { payload -> String in
                let tuple: (fiat: FiatValue, crypto: CryptoCurrency) = payload
                return "1 \(tuple.crypto.displayCode) = \(tuple.fiat.toDisplayString()) \(tuple.fiat.currencyCode)"
            }
    }

    func labeledButtons(for state: BuyCryptoScreenInteractor.State) -> Observable<[CurrencyLabeledButtonViewModel]> {
        switch state {
        case .empty, .inBounds:
            return interactor
                .suggestedAmounts
                .map {
                    $0.enumerated()
                        .map { .init(amount: $0.element, accessibilityId: "\($0.offset)") }
                }
        case .tooLow(min: let amount):
            return .just([
                CurrencyLabeledButtonViewModel(
                    amount: amount,
                    suffix: LocalizedString.LimitView.Min.suffix,
                    style: .currencyTooLow,
                    accessibilityId: AccessibilityId.minimumBuy)
            ])
        case .tooHigh(max: let amount):
            return .just([
                CurrencyLabeledButtonViewModel(
                    amount: amount,
                    suffix: LocalizedString.LimitView.Max.suffix,
                    style: .currencyTooHigh,
                    accessibilityId: AccessibilityId.maximumBuy)
            ])
        }
    }

    private static func trailingButtonViewModel() -> ButtonViewModel {
        var model = ButtonViewModel(
            font: .mainSemibold(14),
            cornerRadius: 8,
            accessibility: .init(id: .value(AccessibilityId.traillingActionButton))
        )
        model.theme = .init(
            backgroundColor: .white,
            borderColor: .mediumBorder,
            contentColor: .primaryButton,
            imageName: nil,
            text: "",
            contentInset: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        )
        return model
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
