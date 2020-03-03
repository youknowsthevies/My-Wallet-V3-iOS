//
//  CustodyWithdrawalSetupInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

final class CustodyWithdrawalSetupInteractor {
    
    typealias InteractionState = LoadingState<Value>
    
    // MARK: - InteractionState Model
    
    struct Value {
        /// The users available balance
        let balance: CryptoValue
        
        /// The users noncustodial address
        let destination: String
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         balanceFetching: AssetBalanceFetching,
         accountRepository: AssetAccountRepositoryAPI) {
        let accountAddress: Single<String> = accountRepository
            .defaultAccount(for: currency.assetType)
            .map { $0?.address.address ?? "" }
        
        Observable
            .combineLatest(
                balanceFetching.calculationState,
                accountAddress.asObservable()
            )
            .map(weak: self) { (self, payload) -> InteractionState in
                let calculationState = payload.0
                let destination = payload.1
                switch calculationState {
                case .value(let balancePairs):
                    return .loaded(
                        next: .init(
                            balance: balancePairs[.custodial].crypto,
                            destination: destination
                        )
                    )
                case .calculating, .invalid:
                    return .loading
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
