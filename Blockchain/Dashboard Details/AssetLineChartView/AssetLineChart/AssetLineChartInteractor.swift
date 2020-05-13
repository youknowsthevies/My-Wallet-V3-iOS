//
//  AssetLineChartInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import RxCocoa

final class AssetLineChartInteractor: AssetLineChartInteracting {
        
    // MARK: - Properties
    
    var state: Observable<AssetLineChart.State.Interaction> {
        return stateRelay
            .asObservable()
    }
    
    private var window: Signal<PriceWindow> {
        return priceWindowRelay.asSignal()
    }
    
    public let priceWindowRelay = PublishRelay<PriceWindow>()
            
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<AssetLineChart.State.Interaction>(value: .loading)
    private let cryptoCurrency: CryptoCurrency
    private let fiatCurrency: FiatCurrency
    private let priceService: PriceServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(cryptoCurrency: CryptoCurrency,
         fiatCurrency: FiatCurrency,
         priceService: PriceServiceAPI = PriceService()) {
        self.fiatCurrency = fiatCurrency
        self.priceService = priceService
        self.cryptoCurrency = cryptoCurrency
        setup()
    }
    
    private func setup() {
        window.emit(onNext: { [weak self] priceWindow in
            guard let self = self else { return }
            self.loadHistoricalPrices(within: priceWindow)
        })
        .disposed(by: disposeBag)
    }
    
    private func loadHistoricalPrices(within window: PriceWindow) {
        let cryptoCurrency = self.cryptoCurrency
        priceService
            .priceSeries(within: window, of: cryptoCurrency, in: fiatCurrency)
            .asObservable()
            .map { .init(delta: $0.delta, currency: cryptoCurrency, prices: $0.prices) }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

