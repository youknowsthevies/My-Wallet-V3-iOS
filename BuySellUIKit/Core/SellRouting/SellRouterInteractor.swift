//
//  SellRouterInteractor.swift
//  BuySellUIKit
//
//  Created by Daniel on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay
import RxCocoa

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
        
        /// Enter amount
        case enterAmount(SellCryptoInteractionData)
                        
        /// Completed state
        case completed
    }
    
    enum Action {
        case next(to: State)
        case previous(from: State)
    }
    
    // MARK: - Properties
    
    var action: Signal<Action> {
        actionRelay.asSignal()
    }
        
    let previousRelay = PublishRelay<Void>()
    
    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    private let actionRelay = PublishRelay<Action>()
    private var disposeBag = DisposeBag()
    
    // MARK: - Setup
        
    // MARK: - Lifecycle
    
    public override func didBecomeActive() {
        super.didBecomeActive()
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)
        
        /// TODO: Daniel -
        /// Navigate to crypto-currency selection first (ATM waiting for it to be built by Paulo)
        /// From there we should go to enter-amount state w/ the accounts.
        let data = SellCryptoInteractionData(
            source: SellCryptoInteractionData.AnyAccount(id: "BTC", currencyType: CryptoCurrency.bitcoin.currency),
            destination: SellCryptoInteractionData.AnyAccount(id: "GBP", currencyType: FiatCurrency.GBP.currency)
        )
        
        let states = States(current: .enterAmount(data), previous: [.inactive])
        apply(action: .next(to: states.current), states: states)
    }
    
    public override func willResignActive() {
        super.willResignActive()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Accessors
    
    private func previous() {
        let last = statesRelay.value.current
        let states = statesRelay.value.statesByRemovingLast()
        apply(action: .previous(from: last), states: states)
    }
        
    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}
