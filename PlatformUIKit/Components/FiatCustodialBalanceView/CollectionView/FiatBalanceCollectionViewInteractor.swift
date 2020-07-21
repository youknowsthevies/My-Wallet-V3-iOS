//
//  FiatBalanceCollectionViewInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import ToolKit

public final class FiatBalanceCollectionViewInteractor {
    
    // MARK: - Types
    
    public typealias State = ValueCalculationState<[FiatCustodialBalanceViewInteractor]>
    
    // MARK: - Exposed Properties
        
    /// Streams the interactors
    public var interactorsState: Observable<State> {
        _ = setup
        return interactorsStateRelay.asObservable()
    }

    var interactors: Observable<[FiatCustodialBalanceViewInteractor]> {
        interactorsState
            .compactMap { $0.value }
            .startWith([])
    }
    
    // MARK: - Injected Properties
    
    private let balanceProvider: BalanceProviding
    
    // MARK: - Accessors
    
    let interactorsStateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    private lazy var setup: Void = {
        balanceProvider.fiatFundsBalances
            .filter { $0.isValue } // All balances must contain value to load
            .map { Array.init(balancePairsCalculationStates: $0) }
            .map { .value($0) }
            .startWith(.calculating)
            .bindAndCatch(to: interactorsStateRelay)
            .disposed(by: disposeBag)
    }()
    
    public init(balanceProvider: BalanceProviding) {
        self.balanceProvider = balanceProvider
    }
}

extension FiatBalanceCollectionViewInteractor: Equatable {
    public static func == (lhs: FiatBalanceCollectionViewInteractor, rhs: FiatBalanceCollectionViewInteractor) -> Bool {
        lhs.interactorsStateRelay.value == rhs.interactorsStateRelay.value
    }
}
