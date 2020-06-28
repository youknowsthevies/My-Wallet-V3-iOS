//
//  NonCustodialActionStateService.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

protocol NonCustodialActionStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<RoutingAction<NonCustodialActionState>> { get }
}

protocol NonCustodialSwapEmitterAPI: class {
    var swapRelay: PublishRelay<Void> { get }
}

protocol NonCustodialActivityEmitterAPI: class {
    var activityRelay: PublishRelay<Void> { get }
}

typealias NonCustodialActionStateServiceAPI = NonCustodialActionStateReceiverServiceAPI &
                                              NonCustodialSwapEmitterAPI &
                                              NonCustodialActivityEmitterAPI &
                                              RoutingNextStateEmitterAPI

final class NonCustodialActionStateService: NonCustodialActionStateServiceAPI {
    
    typealias State = NonCustodialActionState
    typealias Action = RoutingAction<State>
    
    // MARK: - Properties
    
    var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    let swapRelay = PublishRelay<Void>()
    let activityRelay = PublishRelay<Void>()
    let nextRelay = PublishRelay<Void>()
    
    private let actionRelay = PublishRelay<Action>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init() {
        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.apply(action: .next(.actions))
            }
            .disposed(by: disposeBag)
        
        swapRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.apply(action: .next(.swap))
            }
            .disposed(by: disposeBag)
        
        activityRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.apply(action: .next(.activity))
            }
            .disposed(by: disposeBag)
    }
    
    private func apply(action: Action) {
        actionRelay.accept(action)
    }
}
