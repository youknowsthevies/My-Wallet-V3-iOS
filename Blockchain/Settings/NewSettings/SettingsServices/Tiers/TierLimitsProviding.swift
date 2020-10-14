//
//  TierLimitsProviding.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift

protocol TierLimitsProviding {
    var tiers: Observable<KYC.UserTiers> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

final class TierLimitsProvider: TierLimitsProviding {
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    private let tiersService: KYCTiersServiceAPI
    
    var tiers: Observable<KYC.UserTiers> {
        Observable.combineLatest(tiersService.tiers.asObservable(), fetchTriggerRelay).map { $0.0 }
    }
    
    init(tiersService: KYCTiersServiceAPI = resolve()) {
        self.tiersService = tiersService
    }
}
