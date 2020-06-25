//
//  SparklineInteractor.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/23/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxRelay
import RxSwift

public class SparklineInteractor: SparklineInteracting {
    
    // MARK: - SparklineInteracting
    
    public let cryptoCurrency: CryptoCurrency
    
    public var calculationState: Observable<SparklineCalculationState> {
        calculationStateRelay.asObservable()
    }
    
    private let priceService: HistoricalFiatPriceServiceAPI
    private let calculationStateRelay = BehaviorRelay<SparklineCalculationState>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    
    public init(priceService: HistoricalFiatPriceServiceAPI, cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
        self.priceService = priceService
        priceService.calculationState
            .map { state -> SparklineCalculationState in
                switch state {
                case .calculating, .invalid:
                    return .calculating
                case .value(let value):
                    let prices = value.historicalPrices.prices.map { $0.price }
                    return .value(prices)
                }
            }
            .catchErrorJustReturn(.calculating)
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
