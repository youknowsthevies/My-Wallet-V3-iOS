//
//  ActivityItemBalanceFetcher.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public protocol ActivityItemBalanceFetching {
    /// The exchange service
    var exchange: PairExchangeServiceAPI { get }
    
    /// The calculation state of the `FiatCryptoPair`
    var calculationState: Observable<FiatCryptoPairCalculationState> { get }
    
    /// Trigger a refresh on the balance and exchange rate
    func refresh()
}

public final class ActivityItemBalanceFetcher: ActivityItemBalanceFetching {
    
    public let exchange: PairExchangeServiceAPI
    
    public var calculationState: Observable<FiatCryptoPairCalculationState> {
        calculationStateRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let calculationStateRelay = BehaviorRelay<FiatCryptoPairCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    public init(exchange: PairExchangeServiceAPI, cryptoValue: CryptoValue) {
        self.exchange = exchange
        
        exchange
            .fiatPrice
            .map { .init(crypto: cryptoValue, exchangeRate: $0) }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
    
    public func refresh() {
        exchange.fetchTriggerRelay.accept(())
    }
}

