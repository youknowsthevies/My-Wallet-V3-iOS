//
//  ActivityItemBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 4/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class ActivityItemBalanceViewInteractor: AssetBalanceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetBalance.Interaction
    
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(activityItemBalanceFetching: ActivityItemBalanceFetching) {
        activityItemBalanceFetching
            .calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                        fiatValue: result.fiat,
                        cryptoValue: result.crypto
                        )
                    )
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
}

