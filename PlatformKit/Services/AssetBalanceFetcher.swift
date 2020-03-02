//
//  AssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public protocol AssetBalanceFetching {
    
    /// The custodial balance service
    var custodialBalance: CustodialAccountBalanceFetching { get }
    
    /// The balance service
    var balance: AccountBalanceFetching { get }
    
    /// The exchange service
    var exchange: PairExchangeServiceAPI { get }
    
    /// The calculation state of the asset balance
    var calculationState: Observable<AssetFiatCryptoBalanceCalculationState> { get }
    
    /// Trigger a refresh on the balance and exchange rate
    func refresh()
}

public final class AssetBalanceFetcher: AssetBalanceFetching {
    
    // MARK: - Properties
    
    public let custodialBalance: CustodialAccountBalanceFetching
    public let balance: AccountBalanceFetching
    public let exchange: PairExchangeServiceAPI
    
    /// The balance
    public var calculationState: Observable<AssetFiatCryptoBalanceCalculationState> {
        return calculationStateRelay.asObservable()
    }
    
    private let calculationStateRelay = BehaviorRelay<AssetFiatCryptoBalanceCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(custodialBalance: CustodialAccountBalanceFetching,
                balance: AccountBalanceFetching,
                exchange: PairExchangeServiceAPI) {
        self.custodialBalance = custodialBalance
        self.balance = balance
        self.exchange = exchange
        Observable
            .combineLatest(
                balance.balanceObservable,
                custodialBalance.balanceObservable,
                exchange.fiatPrice
            )
            .map {
                return .init(
                    noncustodial: FiatCryptoPair(crypto: $0.0, exchangeRate: $0.2),
                    custodial: FiatCryptoPair(crypto: $0.1, exchangeRate: $0.2)
                )
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    public func refresh() {
        custodialBalance.balanceFetchTriggerRelay.accept(())
        balance.balanceFetchTriggerRelay.accept(())
        exchange.fetchTriggerRelay.accept(())
    }
}
