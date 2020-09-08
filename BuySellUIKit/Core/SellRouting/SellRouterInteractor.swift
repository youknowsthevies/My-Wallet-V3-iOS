//
//  SellRouterInteractor.swift
//  BuySellUIKit
//
//  Created by Daniel on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// Interactors that controls logics related to data-driven transitions between screens within the Sell flow
public final class SellRouterInteractor: Interactor {
    
    // MARK: - Types
                
    /// Comprise all the states so far in the current routing session
    struct States {
    
        /// The actual state of the flow
        let current: State
        
        /// The previous states sorted chronologically
        let previous: [State]
        
        /// All states, ordered
        var all: [State] {
            previous + [current]
        }
        
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
        
        /// Inactive state - pre flow
        case inactive
        
        /// Account Selection Screen
        case accountSelector
        
        /// Fiat Account Selection Screen
        case fiatAccountSelector
        
        /// Enter amount
        case enterAmount(SellCryptoInteractionData)
        
        /// The user is checking-out
        case checkout(CheckoutData)
        
        /// Sell completed
        case pendingOrderCompleted(orderDetails: OrderDetails)
                        
        /// Completed state
        case completed
        
        /// Cancelled Transaction State
        case cancel(CheckoutData)
    }
    
    enum Action {
        case next(to: State)
        case previous(from: State)
        case dismiss
    }
    
    // MARK: - Properties
    
    var action: Signal<Action> {
        actionRelay.asSignal()
    }
        
    public let previousRelay = PublishRelay<Void>()
    private let currencySelectionRelay = BehaviorRelay<CryptoCurrency?>(value: nil)
    
    private lazy var setup: Void = {
        accountSelectionService
            .selectedData
            .flatMap { $0.balance }
            .map { $0.currencyType }
            .compactMap { $0.cryptoCurrency }
            .bindAndCatch(weak: self) { (self, selection) in
                self.currencySelectionRelay.accept(selection)
                let states = States(current: .fiatAccountSelector, previous: [.accountSelector])
                self.apply(action: .next(to: states.current), states: states)
            }
            .disposed(by: disposeBag)
        
        accountSelectionService
            .selectedData
            .flatMap { $0.balance }
            .map { $0.currencyType }
            .compactMap { $0.fiatCurrency }
            .compactMap { selection -> SellCryptoInteractionData? in
                guard let crypto = self.currencySelectionRelay.value else { return nil }
                let data = SellCryptoInteractionData(
                    source: SellCryptoInteractionData.AnyAccount(
                        id: crypto.code,
                        currencyType: crypto.currency
                    ),
                    destination: SellCryptoInteractionData.AnyAccount(
                        id: selection.code,
                        currencyType: selection.currency
                    )
                )
                return data
            }
            .map { States(current: .enterAmount($0), previous: [.inactive]) }
            .bindAndCatch(weak: self) { (self, states) in
                self.apply(action: .next(to: states.current), states: states)
            }
            .disposed(by: disposeBag)
    }()
    
    private let accountSelectionService: AccountSelectionServiceAPI
    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    private let actionRelay = PublishRelay<Action>()
    private var disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(accountSelectionService: AccountSelectionServiceAPI) {
        self.accountSelectionService = accountSelectionService
        super.init()
        _ = setup
    }
        
    // MARK: - Lifecycle
    
    public override func didBecomeActive() {
        super.didBecomeActive()
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)
        
        let states = States(current: .accountSelector, previous: [.inactive])
        apply(action: .next(to: states.current), states: states)
    }
    
    public override func willResignActive() {
        super.willResignActive()
        disposeBag = DisposeBag()
    }
    
    public func nextFromSellCrypto(checkoutData: CheckoutData) {
        let state: State = .checkout(checkoutData)
        let current = statesRelay.value
        let states = States(current: state, previous: [current.current])
        apply(action: .next(to: states.current), states: states)
    }
    
    public func cancelSell(with checkoutData: CheckoutData) {
        let states = self.states(byAppending: .cancel(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
    
    public func orderCompleted() {
        let states = self.states(byAppending: .completed)
        apply(action: .dismiss, states: states)
    }
    
    public func orderPending(with orderDetails: OrderDetails) {
        let checkoutData = CheckoutData(order: orderDetails)
        let state = State.checkout(checkoutData)
        self.apply(
            action: .next(to: state),
            states: self.states(byAppending: state)
        )
    }
    
    public func confirmCheckout(with checkoutData: CheckoutData, isOrderNew: Bool) {
        let state: State
        let data = (checkoutData.order.paymentMethod, isOrderNew)
        switch data {
        case (.funds, true):
            state = .pendingOrderCompleted(
                orderDetails: checkoutData.order
            )
        case (.funds, false):
            state = .inactive
        default:
            fatalError("This should not happen.")
        }
        
        let states = self.states(byAppending: state)
        apply(action: .next(to: state), states: states)
    }
    
    // MARK: - Accessors
    
    private func previous() {
        let last = statesRelay.value.current
        let states = statesRelay.value.statesByRemovingLast()
        let current = states.current
        let action: Action
        switch (last, current) {
        /// Dismiss in case the current state is `inactive`.
        case (_, .inactive):
            action = .dismiss
        default:
            action = .previous(from: last)
        }
        apply(action: action, states: states)
    }
        
    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
    
    private func statesByRemovingLast() -> States {
        statesRelay.value.statesByRemovingLast()
    }
    
    private func states(byAppending state: State) -> States {
        statesRelay.value.states(byAppending: state)
    }
}
