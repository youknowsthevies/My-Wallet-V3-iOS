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
        
    /// Non-Custodial balance service
    var wallet: AccountBalanceFetching { get }
    
    /// Custodial balance service
    var trading: CustodialAccountBalanceFetching { get }
    
    /// Interest balance service
    var savings: CustodialAccountBalanceFetching { get }
        
    /// The calculation state of the asset balance
    var calculationState: Observable<AssetFiatCryptoBalanceCalculationState> { get }
    
    /// Trigger a refresh on the balance and exchange rate
    func refresh()
}

public final class AssetBalanceFetcher: AssetBalanceFetching {
        
    // MARK: - Properties
    
    public let wallet: AccountBalanceFetching
    public let trading: CustodialAccountBalanceFetching
    public let savings: CustodialAccountBalanceFetching
    
    /// The balance
    public var calculationState: Observable<AssetFiatCryptoBalanceCalculationState> {
        calculationStateRelay.asObservable()
    }
    
    private let calculationStateRelay = BehaviorRelay<AssetFiatCryptoBalanceCalculationState>(value: .calculating)
    private let exchange: PairExchangeServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(wallet: AccountBalanceFetching,
                trading: CustodialAccountBalanceFetching,
                savings: CustodialAccountBalanceFetching,
                exchange: PairExchangeServiceAPI) {
        self.trading = trading
        self.wallet = wallet
        self.savings = savings
        self.exchange = exchange
        Observable
            .combineLatest(
                wallet.balanceObservable,
                trading.balanceObservable,
                savings.balanceObservable,
                exchange.fiatPrice
            )
            .map {
                let fiatPrice = $0.3
                return .init(
                    wallet: FiatCryptoPair(crypto: $0.0, exchangeRate: fiatPrice),
                    trading: FiatCryptoPair(crypto: $0.1, exchangeRate: fiatPrice),
                    savings: FiatCryptoPair(crypto: $0.2, exchangeRate: fiatPrice)
                )
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    public func refresh() {
        wallet.balanceFetchTriggerRelay.accept(())
        trading.balanceFetchTriggerRelay.accept(())
        savings.balanceFetchTriggerRelay.accept(())
        exchange.fetchTriggerRelay.accept(())
    }
}
