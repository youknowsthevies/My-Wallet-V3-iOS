//
//  SimpleBuyRepository.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit
import BuySellKit

public final class SimpleBuyStateService: SimpleBuyStateServiceAPI {

    // MARK: - Types
            
    /// Comprise all the states so far in the current Simple-Buy session
    struct States {
        
        /// The actual state of the flow
        let current: State
        
        /// The previous states sorted chronologically
        let previous: [State]
        
        /// A computed inactive state
        static var inactive: States {
            States(current: .inactive, previous: [])
        }
        
        /// Maps the instance of `States` into a new instance where the appended
        /// state is the current
        func states(byAppending state: State) -> States {
            States(
                current: state,
                previous: previous + [current]
            )
        }

        /// Maps the instance of `States` into a new instance where the last
        /// state is trimmed off. In case `previous` is an empty array, `current` will be
        /// `.inactive`.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .inactive,
                previous: previous.dropLast()
            )
        }
    }
    
    /// Marks a past or present state in the state-machine
    public enum State {
        
        /// First time the user performs the simple buy flow
        case intro
        
        /// Fiat Selection
        case selectFiat
        
        /// Fiat selection is not supported in SB
        case unsupportedFiat(FiatCurrency)
                        
        /// In the middle of the buy screen
        case buy
        
        /// Change your fiat type from the `Buy` screen.
        /// Shows only supported `fiat` types
        case changeFiat
        
        /// The user wants to view his payment method types
        case paymentMethods
        
        /// The user would enter add-card flow before checking out
        case addCard(SimpleBuyCheckoutData)
        
        /// During KYC process
        case kyc(SimpleBuyCheckoutData)
        
        /// Pending KYC approval
        case pendingKycApproval(SimpleBuyCheckoutData)
        
        /// The user is checking-out
        case checkout(SimpleBuyCheckoutData)
        
        /// The user authorized his bank wire
        case transferDetails(SimpleBuyCheckoutData)
        
        /// The user authorized his card payment and should now be referred to partner
        case authorizeCard(order: SimpleBuyOrderDetails)

        /// The user may cancel their transfer
        case transferCancellation(SimpleBuyCheckoutData)

        /// The user has a pending order
        case pendingOrderDetails(SimpleBuyCheckoutData)

        /// Purchase completed
        case pendingOrderCompleted(amount: CryptoValue, orderId: String)
        
        /// Inactive state - no buy flow is performed at the moment
        case inactive
        
        var isInactive: Bool {
            switch self {
            case .inactive:
                return true
            default:
                return false
            }
        }
    }
    
    public enum Action {
        case next(to: State)
        case previous(from: State)
        case dismiss
    }
        
    // MARK: - Properties

    var states: Observable<States> {
        statesRelay.asObservable()
    }
    
    var currentState: Observable<SimpleBuyStateService.State> {
        states.map { $0.current }
    }
    
    public var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    public let nextRelay = PublishRelay<Void>()
    public let previousRelay = PublishRelay<Void>()

    public let cache: SimpleBuyEventCache
    
    private let supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI
    private let uiUtilityProvider: UIUtilityProviderAPI
    private let pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI
    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    private let actionRelay = PublishRelay<Action>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(uiUtilityProvider: UIUtilityProviderAPI,
                pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI,
                supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI,
                cache: SimpleBuyEventCache) {
        self.supportedPairsInteractor = supportedPairsInteractor
        self.uiUtilityProvider = uiUtilityProvider
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.cache = cache
        
        nextRelay
            .observeOn(MainScheduler.instance)
            .bind(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bind(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)
    }
    
    public func addCardStateService(with checkoutData: SimpleBuyCheckoutData) -> AddCardStateService {
        let addCardStateService = AddCardStateService()
        addCardStateService.completionCardData
            .bind { [weak self] cardData in
                guard let self = self else { return }
                let checkoutData = checkoutData.checkoutData(byAppending: cardData)
                self.previous()
                self.nextFromBuyCrypto(with: checkoutData)
            }
            .disposed(by: disposeBag)
        
        addCardStateService.cancellation
            .bind { [weak self] in
                self?.previous()
            }
            .disposed(by: disposeBag)

        return addCardStateService
    }
        
    // TODO: Look into reactive state machine
    private func next() {
        let states = statesRelay.value
        let state: State
        switch states.current {
        case .inactive:
            startFlow()
        case .intro:
            state = .selectFiat
            apply(
                action: .next(to: state),
                states: states.states(byAppending: state)
            )
        case .kyc(let data):
            state = .pendingKycApproval(data)
            apply(
                action: .next(to: state),
                states: states.states(byAppending: state)
            )
        case .pendingKycApproval(let data):
            if data.isSuggestedCard {
                state = .addCard(data)
            } else {
                state = .checkout(data)
            }
            apply(
                action: .next(to: state),
                states: states.states(byAppending: state)
            )
        case .transferDetails,
             .pendingOrderDetails,
             .transferCancellation,
             .unsupportedFiat,
             .changeFiat:
            state = .inactive
            apply(
                action: .dismiss,
                states: states.states(byAppending: state)
            )
        case .buy, .checkout, .paymentMethods, .selectFiat, .addCard, .authorizeCard, .pendingOrderCompleted:
            fatalError("\(#function) should not get called with \(states.current). use `SimpleBuyCheckoutServiceAPI` instead")
        }
    }
    
    private func previous() {
        let last = statesRelay.value.current
        let states = statesRelay.value.statesByRemovingLast()
        let current = states.current
        let action: Action
        switch (last, current) {
        /// Dismiss in case the current state is `inactive`.
        /// Dismiss in case the last state is `pendingKycApproval` (end user tapped the continue button)
        case (_, .inactive),
             (.pendingKycApproval, _):
            action = .dismiss
        default:
            action = .previous(from: last)
        }
        apply(action: action, states: states)
    }
        
    private func startFlow() {
        let cache = self.cache
        let isFiatCurrencySupported: Single<Bool> = supportedPairsInteractor.valueSingle
            .map { !$0.pairs.isEmpty }
        Single
            .zip(
                pendingOrderDetailsService.checkoutData,
                isFiatCurrencySupported
            )
            .handleLoaderForLifecycle(
                loader: uiUtilityProvider.loader,
                style: .circle
            )
            .map { data -> State in
                let isFiatCurrencySupported = data.1
                if let data = data.0 {
                    switch data.detailType {
                    case .order(let details):
                        switch data.detailType.paymentMethod {
                        case .card:
                            if details.is3DSConfirmedCardOrder {
                                return .pendingOrderCompleted(
                                    amount: details.cryptoValue,
                                    orderId: details.identifier
                                )
                            } else {
                                return .checkout(data)
                            }
                        case .bankTransfer:
                            switch details.state {
                            case .pendingConfirmation:
                                return .checkout(data)
                            default:
                                return .pendingOrderDetails(data)
                            }
                        }

                    case .candidate:
                        fatalError("Impossible case to reach")
                    }
                } else {
                    return cache[.hasShownIntroScreen] ? (isFiatCurrencySupported ? .buy : .selectFiat) : .intro
                }
            }
            .subscribe(
                onSuccess: { [weak self] state in
                    guard let self = self else { return }
                    /// The user already has a pending order, so
                    /// mark the intro screen as `shown`.
                    switch state {
                    case .checkout, .pendingOrderDetails, .pendingOrderCompleted, .transferDetails:
                        cache[.hasShownIntroScreen] = true
                    default:
                        break
                    }
                    
                    self.apply(
                        action: .next(to: state),
                        states: self.statesRelay.value.states(byAppending: state)
                    )
                },
                onError: { [weak uiUtilityProvider] error in
                    uiUtilityProvider?.alert.error(in: nil, action: nil)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
        cache(state: states.current)
    }
    
    private func cache(state: State) {
        switch state {
        case .buy:
            cache[.hasShownBuyScreen] = true
        case .intro:
            cache[.hasShownIntroScreen] = true
        default:
            break
        }
    }
}

// MARK: - SimpleBuyElibilityRelayAPI

extension SimpleBuyStateService {
    
    public func ineligible(with currency: FiatCurrency) {
        let states = statesRelay.value.states(byAppending: .unsupportedFiat(currency))
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - SimpleBuyCheckoutServiceAPI

extension SimpleBuyStateService {
    
    public func nextFromBuyCrypto(with checkoutData: SimpleBuyCheckoutData) {
        let state: State
        if checkoutData.isSuggestedCard {
            state = .addCard(checkoutData)
        } else {
            state = .checkout(checkoutData)
        }
        let states = statesRelay.value.states(byAppending: state)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func kyc(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .kyc(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }

    public func ineligible(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .pendingKycApproval(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }

    public func paymentMethods() {
        let states = statesRelay.value.states(byAppending: .paymentMethods)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func changeCurrency() {
        let states = statesRelay.value.states(byAppending: .changeFiat)
        apply(action: .next(to: states.current), states: states)
    }

    public func transferDetails(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .transferDetails(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - SimpleBuyCurrencySelectionServiceAPI

extension SimpleBuyStateService {
    public func currencySelected() {
        let states = statesRelay.value.states(byAppending: .buy)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func reselectCurrency() {
        previousRelay.accept(())
        let states = statesRelay.value.states(byAppending: .selectFiat)
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - SimpleBuyConfirmCheckoutServiceAPI

extension SimpleBuyStateService {
    public func confirmCheckout(with checkoutData: SimpleBuyCheckoutData, isOrderNew: Bool) {
        let state: State
        let data = (checkoutData.detailType, checkoutData.detailType.paymentMethod, isOrderNew)
        switch data {
        case (.order, .bankTransfer, true):
            state = .transferDetails(checkoutData)
        case (.order, .bankTransfer, false):
            state = .inactive
        case (.order(let details), .card, _):
            if details.isPending3DSCardOrder {
                state = .authorizeCard(order: details)
            } else {
                state = .inactive
            }
        default:
            fatalError("Cannot executed checkout with \(data)")
        }
        let states = statesRelay.value.states(byAppending: state)
        apply(action: .next(to: state), states: states)
    }
}

extension SimpleBuyStateService {
    public func cancelTransfer(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .transferCancellation(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}

extension SimpleBuyStateService {
    public func cardAuthorized(with paymentMethodId: String) {
        guard case .authorizeCard(order: let order) = statesRelay.value.current else {
            return
        }
        let states = statesRelay.value.states(
            byAppending: .pendingOrderCompleted(
                amount: order.cryptoValue,
                orderId: order.identifier
            )
        )
        apply(action: .next(to: states.current), states: states)
    }
}

extension SimpleBuyStateService {
    public func orderCompleted() {
        let states = statesRelay.value.states(byAppending: .inactive)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func orderPending(with orderDetails: SimpleBuyOrderDetails) {
        let checkoutData = SimpleBuyCheckoutData(orderDetails: orderDetails)
        let state = State.checkout(checkoutData)
        self.apply(
            action: .next(to: state),
            states: self.statesRelay.value.states(byAppending: state)
        )
    }
}
