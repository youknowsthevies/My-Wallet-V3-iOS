//
//  AssetPriceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class AssetPriceViewInteractor: AssetPriceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction
    
    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
            
    // MARK: - Private Accessors
    
    private lazy var setup: Void = {
        historicalPriceProvider.calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    let delta = result.historicalPrices.delta
                    let currency = result.historicalPrices.currency
                    let window = result.priceWindow
                    let currentPrice = result.currentFiatValue
                    let fiatChange: FiatValue = .create(
                        amount: result.historicalPrices.fiatChange,
                        currency: result.currentFiatValue.currencyType
                    )
                    return .loaded(
                        next: .init(
                            time: window.time(for: currency),
                            fiatValue: currentPrice,
                            changePercentage: delta,
                            fiatChange: fiatChange
                        )
                    )
                }
            }
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    private let historicalPriceProvider: HistoricalFiatPriceServiceAPI
    
    // MARK: - Setup
    
    public init(historicalPriceProvider: HistoricalFiatPriceServiceAPI) {
        self.historicalPriceProvider = historicalPriceProvider
    }
}
