//
//  UpdateMobileRouterStateServiceAPI.swift
//  Blockchain
//
//  Created by AlexM on 3/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformUIKit

protocol UpdateMobileStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<UpdateMobileRouterStateService.Action> { get }
}

/// A composition of all of Simple-Buy state-services
typealias UpdateMobileStateServiceAPI = UpdateMobileStateReceiverServiceAPI &
                                        RoutingNextStateEmitterAPI &
                                        RoutingPreviousStateEmitterAPI
