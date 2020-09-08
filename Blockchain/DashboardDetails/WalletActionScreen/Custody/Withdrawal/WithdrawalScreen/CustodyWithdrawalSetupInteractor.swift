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
    
    struct Value: Equatable {
        /// The users available balance
        let totalBalance: CryptoValue

        /// The users available balance
        let withdrawableBalance: CryptoValue
        
        /// The users noncustodial address
        let destination: String

        var remaining: CryptoValue {
            guard let result = try? totalBalance - withdrawableBalance else {
                return CryptoValue.zero(currency: totalBalance.currencyType)
            }
            guard result.isZero || result.isPositive else {
                return CryptoValue.zero(currency: totalBalance.currencyType)
            }
            return result
        }
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
            ) { (balanceState: $0, destination: $1) }
            .map { payload -> Value in
                switch payload.balanceState {
                case .absent:
                    return Value(
                        totalBalance: .zero(currency: currency),
                        withdrawableBalance: .zero(currency: currency),
                        destination: payload.destination
                    )
                case .present(let balance):
                    return Value(
                        totalBalance: balance.available.cryptoValue!,
                        withdrawableBalance: balance.withdrawable.cryptoValue!,
                        destination: payload.destination
                    )
                }
            }
            .map { InteractionState.loaded(next: $0) }
            .asObservable()
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
