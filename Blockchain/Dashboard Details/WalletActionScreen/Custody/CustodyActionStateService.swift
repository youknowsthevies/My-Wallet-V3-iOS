//
//  CustodySendStateService.swift
//  Blockchain
//
//  Created by AlexM on 2/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

enum RoutingAction<A> {
    case next(A)
    case previous
    case dismiss
}

protocol CustodyActionStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<RoutingAction<CustodyActionState>> { get }
}

protocol CustodyActivityEmitterAPI: class {
    var activityRelay: PublishRelay<Void> { get }
}

typealias CustodyActionStateServiceAPI = CustodyActionStateReceiverServiceAPI &
                                         RoutingNextStateEmitterAPI &
                                         CustodyActivityEmitterAPI &
                                         RoutingPreviousStateEmitterAPI

final class CustodyActionStateService: CustodyActionStateServiceAPI {
    typealias State = CustodyActionState
    typealias Action = RoutingAction<State>

    // MARK: - Types
            
    struct States {
        
        /// The actual state of the flow
        let current: State
        
        /// The previous states sorted chronologically
        let previous: [State]
        
        /// The starting state
        static var start: States {
            States(current: .start, previous: [])
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
        /// state is trimmed off.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .end,
                previous: previous.dropLast()
            )
        }
    }
    
    // MARK: - Types
    
    private enum Constant {
        static let introScreenShown = "custodySendInterstitialViewed"
    }
    
    // MARK: - Properties

    var hasShownCustodyIntroductionScreen: Bool {
        cacheSuite.bool(forKey: Constant.introScreenShown)
    }
    
    var states: Observable<States> {
        statesRelay.asObservable()
    }
    
    var currentState: Observable<CustodyActionStateService.State> {
        states.map { $0.current }
    }
    
    var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    let nextRelay = PublishRelay<Void>()
    let previousRelay = PublishRelay<Void>()
    let activityRelay = PublishRelay<Void>()
    
    private let statesRelay = BehaviorRelay<States>(value: .start)
    private let actionRelay = PublishRelay<Action>()
    private let cacheSuite: CacheSuite
    private let wallet: Wallet
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(cacheSuite: CacheSuite = UserDefaults.standard,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
        self.cacheSuite = cacheSuite
        
        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)

        activityRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .activity)
                self.apply(action: .next(.activity), states: nextStates)
            }
            .disposed(by: disposeBag)
    }
    
    private func next() {
        let action: Action
        var state: State
        let states = statesRelay.value
        switch states.current {
        case .start:
            state = .send
            action = .next(state)
        case .introduction:
            cacheSuite.set(true, forKey: Constant.introScreenShown)
            state = wallet.isRecoveryPhraseVerified() ? .withdrawal : .backupAfterIntroduction
            action = .next(state)
        case .backupAfterIntroduction, .backup:
            state = wallet.isRecoveryPhraseVerified() ? .withdrawalAfterBackup : .end
            action = .next(state)
        case .activity:
            state = .end
            action = .next(state)
        case .send:
            state = hasShownCustodyIntroductionScreen ? .backup : .introduction
            state = wallet.isRecoveryPhraseVerified() ? .withdrawal : state
            action = .next(state)
        case .withdrawal, .withdrawalAfterBackup:
            state = .end
            action = .next(state)
        case .end:
            state = .end
            action = .next(state)
        }
        let nextStates = states.states(byAppending: state)
        apply(action: action, states: nextStates)
    }
    
    private func previous() {
        let states = statesRelay.value.statesByRemovingLast()
        let action: Action
        switch states.current {
        case .end, .start, .introduction, .backupAfterIntroduction, .send:
            action = .dismiss
        default:
            action = .previous
        }
        apply(action: action, states: states)
    }
    
    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}
