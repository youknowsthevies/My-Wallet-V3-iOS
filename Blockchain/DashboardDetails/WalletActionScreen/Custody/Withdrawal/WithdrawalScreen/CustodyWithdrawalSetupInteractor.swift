//
//  CustodyWithdrawalSetupInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class CustodyWithdrawalSetupInteractor {
    
    typealias InteractionState = LoadingState<Value>
    
    // MARK: - InteractionState Model
    
    struct Value {
        /// The users available balance
        let totalBalance: CryptoValue

        /// The users available balance
        let withdrawableBalance: CryptoValue
        
        /// The users noncustodial address
        let destination: String
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         tradingBalanceService: TradingBalanceServiceAPI,
         accountRepository: AssetAccountRepositoryAPI) {
        let accountAddress: Single<String> = accountRepository
            .defaultAccount(for: currency)
            .map { $0.address.publicKey }
            .catchError { error -> Single<String> in
                fatalError("No \(currency.code) address, error: \(error)")
            }
        
        Single
            .zip(
                tradingBalanceService.balance(for: currency.currency),
                accountAddress
            )
            .map(weak: self) { (self, payload) -> InteractionState in
                let balance = payload.0
                let destination = payload.1
                switch balance {
                case .absent:
                    return .loading
                case .present(let balance):
                    return InteractionState.loaded(
                        next: Value(
                            totalBalance: balance.available.cryptoValue!,
                            withdrawableBalance: balance.withdrawable.cryptoValue!,
                            destination: destination
                        )
                    )
                }
            }
            .asObservable()
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
