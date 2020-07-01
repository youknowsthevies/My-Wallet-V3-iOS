//
//  WalletBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 5/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class WalletBalanceViewInteractor {
    
    typealias InteractionState = LoadingState<WalletBalance>
    
    public struct WalletBalance {
        
        /// The wallet's balance in fiat
        let fiatValue: FiatValue
        /// The wallet's fiat currency code
        var fiatCurrency: FiatCurrency {
            fiatValue.currencyType
        }
        
        public init(fiatValue: FiatValue) {
            self.fiatValue = fiatValue
        }
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(balanceProviding: BalanceProviding) {
        balanceProviding.fiatBalance
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
