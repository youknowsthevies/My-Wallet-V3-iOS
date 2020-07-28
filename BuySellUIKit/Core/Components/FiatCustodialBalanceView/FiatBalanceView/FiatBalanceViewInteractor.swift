//
//  FiatBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 6/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class FiatBalanceViewInteractor {
    
    // MARK: - Types
    
    public typealias InteractionState = FiatBalanceViewAsset.State.Interaction
    
    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    public init(balance: MoneyValueBalancePairs) {
        stateRelay.accept(
            .loaded(
                next: .init(
                    base: balance.base.fiatValue!,
                    quote: balance.quote.fiatValue!
                )
            )
        )
    }
}
