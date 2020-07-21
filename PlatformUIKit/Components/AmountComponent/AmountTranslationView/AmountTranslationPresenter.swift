//
//  AmountTranslationPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Localization
import ToolKit
import PlatformKit

extension Accessibility.Identifier {
    enum Amount {
        static let max = "Amount.useMaxButton"
        static let min = "Amount.useMinButton"
    }
}

public final class AmountTranslationPresenter {
    
    // MARK: - Types
    
    enum State {
        case showLimitButton(CurrencyLabeledButtonViewModel)
        case showSecondaryAmountLabel
    }
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen.LimitView
    private typealias AccessibilityId = Accessibility.Identifier.Amount

    // MARK: - Public Properties
    
    public let swapButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    
    // MARK: - Internal Properties
    
    var activeAmountInput: Driver<ActiveAmountInput> {
        interactor.activeInputRelay.asDriver()
    }
    
    var state: Driver<State> {
        stateRelay.asDriver()
    }
    
    var swapButtonVisibility: Driver<Visibility> {
        swapButtonVisibilityRelay.asDriver()
    }
    
    let swapButtonTapRelay = PublishRelay<Void>()
    
    // MARK: - Injected
    
    let interactor: AmountTranslationInteractor
    let fiatPresenter: InputAmountLabelPresenter
    let cryptoPresenter: InputAmountLabelPresenter
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let maxTappedAnalyticsEvent: AnalyticsEvent
    private let minTappedAnalyticsEvent: AnalyticsEvent
    
    // MARK: - Accessors
            
    private let stateRelay = BehaviorRelay<State>(value: .showSecondaryAmountLabel)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(interactor: AmountTranslationInteractor,
                analyticsRecorder: AnalyticsEventRecording,
                minTappedAnalyticsEvent: AnalyticsEvent,
                maxTappedAnalyticsEvent: AnalyticsEvent) {
        self.interactor = interactor
        self.fiatPresenter = .init(interactor: interactor.fiatInteractor, currencyCodeSide: .leading)
        self.cryptoPresenter = .init(interactor: interactor.cryptoInteractor, currencyCodeSide: .trailing)
        self.analyticsRecorder = analyticsRecorder
        self.minTappedAnalyticsEvent = minTappedAnalyticsEvent
        self.maxTappedAnalyticsEvent = maxTappedAnalyticsEvent
        
        swapButtonTapRelay
            .withLatestFrom(interactor.activeInput)
            .map { $0.inverted }
            .bind(to: interactor.activeInputRelay)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                interactor.state,
                interactor.activeInput
            )
            .map(weak: self) { (self, payload) in
                self.setupButton(by: payload.0, activeInput: payload.1)
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }

    private func setupButton(by state: AmountTranslationInteractor.State,
                             activeInput: ActiveAmountInput) -> State {
        let viewModel: CurrencyLabeledButtonViewModel
        switch state {
        case .empty, .inBounds:
            return .showSecondaryAmountLabel
        case .maxLimitExceeded(let maxValue):
            viewModel = CurrencyLabeledButtonViewModel(
                amount: maxValue.base,
                suffix: LocalizedString.Max.useMax,
                style: .currencyOutOfBounds,
                accessibilityId: AccessibilityId.max
            )
            viewModel.elementOnTap
                .map { "\($0)" }
                .emit(onNext: { [weak self] amount in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: self.maxTappedAnalyticsEvent)
                    self.interactor.set(amount: amount)
                })
                .disposed(by: disposeBag)
            return .showLimitButton(viewModel)
        case .minLimitExceeded(let minValue):
            viewModel = CurrencyLabeledButtonViewModel(
                amount: minValue.base,
                suffix: LocalizedString.Min.useMin,
                style: .currencyOutOfBounds,
                accessibilityId: AccessibilityId.min
            )
            viewModel.elementOnTap
                .map { "\($0)" }
                .emit(onNext: { [weak self] amount in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: self.minTappedAnalyticsEvent)
                    self.interactor.set(amount: amount)
                })
                .disposed(by: disposeBag)
            return .showLimitButton(viewModel)
        }
    }
}

