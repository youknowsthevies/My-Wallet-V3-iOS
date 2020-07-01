//
//  AssetBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class AssetBalanceViewInteractor: AssetBalanceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetBalance.Interaction
    
    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(assetBalanceFetching: AssetBalanceFetching) {
        assetBalanceFetching.calculationState
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
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

public final class AssetBalanceTypeViewInteractor: AssetBalanceTypeViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetBalance.Interaction
    
    // MARK: - Exposed Properties
    
    public let balanceType: BalanceType
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(assetBalanceFetching: AssetBalanceFetching, balanceType: BalanceType) {
        self.balanceType = balanceType
        
        assetBalanceFetching.calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result[balanceType].fiat,
                            cryptoValue: result[balanceType].crypto
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

