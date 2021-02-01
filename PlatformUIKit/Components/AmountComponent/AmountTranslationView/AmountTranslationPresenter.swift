//
//  AmountTranslationPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

extension Accessibility.Identifier {
    enum Amount {
        static let max = "Amount.useMaxButton"
        static let min = "Amount.useMinButton"
        static let warning = "Amount.warning"
        static let error = "Amount.error"
    }
}

public final class AmountTranslationPresenter {
    
    // MARK: - Types
    
    public struct DisplayBundle {
        public struct Events {
            public let minTappedAnalyticsEvent: AnalyticsEvent
            public let maxTappedAnalyticsEvent: AnalyticsEvent
            
            public init(min: AnalyticsEvent, max: AnalyticsEvent) {
                self.minTappedAnalyticsEvent = min
                self.maxTappedAnalyticsEvent = max
            }
        }
        
        public struct Strings {
            public let useMin: String
            public let useMax: String
            
            public init(useMin: String, useMax: String) {
                self.useMin = useMin
                self.useMax = useMax
            }
        }
        
        public struct AccessibilityIdentifiers {
            public init() {
                
            }
        }
        
        public let strings: Strings
        public let events: Events
        public let accessibilityIdentifiers: AccessibilityIdentifiers
        
        public init(events: Events,
                    strings: Strings,
                    accessibilityIdentifiers: AccessibilityIdentifiers) {
            self.events = events
            self.strings = strings
            self.accessibilityIdentifiers = accessibilityIdentifiers
        }
    }
    
    public enum Input {
        case input(Character)
        case delete
    }
    
    public enum State {
        case empty
        case warning(ButtonViewModel)
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
    let displayBundle: DisplayBundle
    
    private let analyticsRecorder: AnalyticsEventRecording
    
    // MARK: - Accessors
            
    private let stateRelay = BehaviorRelay<State>(value: .showSecondaryAmountLabel)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(interactor: AmountTranslationInteractor,
                analyticsRecorder: AnalyticsEventRecording,
                displayBundle: DisplayBundle,
                inputTypeToggleVisiblity: Visibility = .hidden) {
        self.displayBundle = displayBundle
        self.swapButtonVisibilityRelay.accept(inputTypeToggleVisiblity)
        self.interactor = interactor
        self.fiatPresenter = .init(interactor: interactor.fiatInteractor, currencyCodeSide: .leading)
        self.cryptoPresenter = .init(interactor: interactor.cryptoInteractor, currencyCodeSide: .trailing)
        self.analyticsRecorder = analyticsRecorder
        
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
    
    public func connect(input: Driver<AmountTranslationPresenter.Input>) -> Driver<State> {
        interactor.connect(input: input.map(\.toInteractorInput))
            .map { [weak self] state -> State in
                guard let self = self else { return .empty }
                
                return self.setupButton(by: state, activeInput: self.interactor.activeInputRelay.value)
            }
    }

    private func setupButton(by state: AmountTranslationInteractor.State,
                             activeInput: ActiveAmountInput) -> State {
        switch state {
        case .empty, .inBounds:
            return .showSecondaryAmountLabel
        case let .error(message):
            let viewModel = ButtonViewModel.currencyOutOfBounds(
                with: message,
                accessibilityId: AccessibilityId.error
            )
            return .warning(viewModel)
        case let .warning(message, action):
            let viewModel = ButtonViewModel.warning(
                with: message,
                accessibilityId: AccessibilityId.warning
            )
            viewModel.tap
                .throttle(.seconds(1))
                .emit(onNext: { _ in
                    action()
                })
                .disposed(by: disposeBag)
            return .warning(viewModel)
        case .maxLimitExceeded(let maxValue):
            /// The min/max string value can include one parameter. If it does not
            /// just show the localized string.
            var message = ""
            if displayBundle.strings.useMax.contains("%@") {
                message = String(format: displayBundle.strings.useMax, maxValue.toDisplayString(includeSymbol: true))
            } else {
                message = displayBundle.strings.useMax
            }
            let viewModel = ButtonViewModel.currencyOutOfBounds(
                with: message,
                accessibilityId: AccessibilityId.max
            )
            viewModel.tap
                .throttle(.seconds(1))
                .emit(onNext: { [maxValue, weak self] in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: self.displayBundle.events.maxTappedAnalyticsEvent)
                    self.interactor.set(amount: maxValue)
                })
                .disposed(by: disposeBag)
            return .warning(viewModel)
        case .minLimitExceeded(let minValue):
            /// The min/max string value can include one parameter. If it does not
            /// just show the localized string.
            var message = ""
            if displayBundle.strings.useMin.contains("%@") {
                message = String(format: displayBundle.strings.useMin, minValue.toDisplayString(includeSymbol: true))
            } else {
                message = displayBundle.strings.useMin
            }
            let viewModel = ButtonViewModel.currencyOutOfBounds(
                with: message,
                accessibilityId: AccessibilityId.min
            )
            viewModel.tap
                .throttle(.seconds(1))
                .emit(onNext: { [minValue, weak self] in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: self.displayBundle.events.minTappedAnalyticsEvent)
                    self.interactor.set(amount: minValue)
                })
                .disposed(by: disposeBag)
            return .warning(viewModel)
        }
    }
}

extension AmountTranslationPresenter.Input {
    internal var toInteractorInput: AmountTranslationInteractor.Input {
        switch self {
        case .input(let value):
            return .insert(value)
        case .delete:
            return .remove
        }
    }
}

