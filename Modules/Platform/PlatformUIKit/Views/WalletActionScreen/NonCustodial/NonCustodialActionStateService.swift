//
//  NonCustodialActionStateService.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

protocol NonCustodialActionStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<RoutingAction<NonCustodialActionState>> { get }
}

protocol NonCustodialActionEmitterAPI: class {
    var selectionRelay: PublishRelay<RoutingAction<NonCustodialActionState>> { get }
}

typealias NonCustodialActionStateServiceAPI = NonCustodialActionStateReceiverServiceAPI &
                                              RoutingNextStateEmitterAPI &
                                              NonCustodialActionEmitterAPI

final class NonCustodialActionStateService: NonCustodialActionStateServiceAPI {
    
    typealias State = NonCustodialActionState
    typealias Action = RoutingAction<State>
    
    // MARK: - Properties
    
    var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    let nextRelay = PublishRelay<Void>()
    let selectionRelay = PublishRelay<Action>()
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
        
        selectionRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self, action) in
                self.apply(action: action)
            }
            .disposed(by: disposeBag)
    }
    
    private func apply(action: Action) {
        actionRelay.accept(action)
    }
}
