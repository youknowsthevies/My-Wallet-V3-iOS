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

final class SimpleBuyStateService: RoutingStateEmitterAPI,
                                   SimpleBuyStateReceiverServiceAPI,
                                   SimpleBuyStateCacheProviderAPI {

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
    enum State {
        
        /// First time the user performs the simple buy flow
        case intro
                        
        /// In the middle of the buy screen
        case buy
        
        /// During KYC process
        case kyc(SimpleBuyCheckoutData)
        
        /// Pending KYC approval
        case pendingKycApproval(SimpleBuyCheckoutData)
        
        /// The user is checking-out
        case checkout(SimpleBuyCheckoutData)
        
        /// The user is after the checkout
        case transferDetails(SimpleBuyCheckoutData)
        
        /// The user may cancel their transfer
        case transferCancellation(SimpleBuyCheckoutData)
        
        /// The user has a pending order
        case pendingOrderDetails(SimpleBuyCheckoutData)
        
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
    
    enum Action {
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
    
    var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    let nextRelay = PublishRelay<Void>()
    let previousRelay = PublishRelay<Void>()

    let cache: SimpleBuyEventCache
    
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    private let pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI
    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    private let actionRelay = PublishRelay<Action>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(alertPresenter: AlertViewPresenter = .shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI = SimpleBuyServiceProvider.default.pendingOrderDetails,
         cache: SimpleBuyEventCache = SimpleBuyServiceProvider.default.cache) {
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
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
    
    // TODO: Look into reactive state machine
    private func next() {
        let states = statesRelay.value
        let state: State
        switch states.current {
        case .inactive:
            startFlow()
        case .intro:
            state = .buy
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
            state = .checkout(data)
            apply(
                action: .next(to: state),
                states: states.states(byAppending: state)
            )
        case .transferDetails, .pendingOrderDetails, .transferCancellation:
            state = .inactive
            apply(
                action: .dismiss,
                states: states.states(byAppending: state)
            )
        case .buy, .checkout:
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
        case (_, .inactive), (.pendingKycApproval, _):
            action = .dismiss
        default:
            action = .previous(from: last)
        }
        apply(action: action, states: states)
    }
    
    private func startFlow() {
        let cache = self.cache
        pendingOrderDetailsService.orderDetails
            .handleLoaderForLifecycle(
                loader: loadingViewPresenter,
                style: .circle
            )
            .map { data -> State in
                if let data = data {
                    return .pendingOrderDetails(data)
                } else {
                    return cache[.hasShownIntroScreen] ? .buy : .intro
                }
            }
            .subscribe(
                onSuccess: { [weak self] state in
                    guard let self = self else { return }
                    /// The user already has a pending order, so
                    /// mark the intro screen as `shown`.
                    if case .pendingOrderDetails = state {
                        cache[.hasShownIntroScreen] = true
                    }
                    
                    self.apply(
                        action: .next(to: state),
                        states: self.statesRelay.value.states(byAppending: state)
                    )
                },
                onError: { [weak alertPresenter] error in
                    guard let alertPresenter = alertPresenter else { return }
                    alertPresenter.notify(
                        content: .init(
                            title: LocalizationConstants.SimpleBuy.ErrorAlert.title,
                            message: LocalizationConstants.SimpleBuy.ErrorAlert.message
                        )
                    )
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

// MARK: - SimpleBuyCheckoutServiceAPI

extension SimpleBuyStateService: SimpleBuyCheckoutServiceAPI {
    func checkout(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .checkout(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
    
    func kyc(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .kyc(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - SimpleBuyConfirmCheckoutServiceAPI

extension SimpleBuyStateService: SimpleBuyConfirmCheckoutServiceAPI {
    func confirmCheckout(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .transferDetails(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}

extension SimpleBuyStateService: SimpleBuyCancelTransferServiceAPI {
    func cancelTransfer(with checkoutData: SimpleBuyCheckoutData) {
        let states = statesRelay.value.states(byAppending: .transferCancellation(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}
