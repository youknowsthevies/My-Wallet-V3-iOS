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
        _ = setup
        return stateRelay.asObservable()
    }
            
    // MARK: - Private Accessors
    
    private lazy var setup: Void = {
        assetBalanceFetching.calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result.quote,
                            cryptoValue: result.base
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    private let assetBalanceFetching: AssetBalanceFetching
    
    // MARK: - Setup
    
    public init(assetBalanceFetching: AssetBalanceFetching) {
        self.assetBalanceFetching = assetBalanceFetching
    }
}

public final class AssetBalanceTypeViewInteractor: AssetBalanceTypeViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetBalance.Interaction
    
    // MARK: - Exposed Properties
    
    public let balanceType: BalanceType
    
    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }
            
    // MARK: - Private Accessors
    
    private lazy var setup: Void = {
        assetBalanceFetching.calculationState
            .map(weak: self) { (self, state) -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result[self.balanceType].quote,
                            cryptoValue: result[self.balanceType].base
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    private let assetBalanceFetching: AssetBalanceFetching
    
    // MARK: - Setup
    
    public init(assetBalanceFetching: AssetBalanceFetching, balanceType: BalanceType) {
        self.balanceType = balanceType
        self.assetBalanceFetching = assetBalanceFetching
    }
}

