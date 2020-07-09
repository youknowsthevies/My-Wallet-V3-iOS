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
        _ = setup
        return calculationStateRelay.asObservable()
    }
    
    private lazy var setup: Void = {
        exchange
            .fiatPrice
            .map(weak: self) { (self, fiatPrice) -> FiatCryptoPair in
                FiatCryptoPair(crypto: self.cryptoValue, exchangeRate: fiatPrice)
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Private Properties
    
    private let calculationStateRelay = BehaviorRelay<FiatCryptoPairCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    private let cryptoValue: CryptoValue
    
    public init(exchange: PairExchangeServiceAPI, cryptoValue: CryptoValue) {
        self.exchange = exchange
        self.cryptoValue = cryptoValue
    }
    
    public func refresh() {
        exchange.fetchTriggerRelay.accept(())
    }
}

