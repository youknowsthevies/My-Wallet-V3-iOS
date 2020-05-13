//
//  AssetLineChartTableViewCellInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/15/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit
import RxCocoa
import PlatformKit
import Charts

final class AssetLineChartTableViewCellInteractor: AssetLineChartTableViewCellInteracting {
    
    // MARK: - AssetLineChartTableViewCellInteracting
    
    let lineChartUserInteractor: AssetLineChartUserInteracting
    let lineChartInteractor: AssetLineChartInteracting
    let assetPriceViewInteractor: AssetPriceViewInteracting
    let window = PublishRelay<PriceWindow>()
    var isDeselected: Driver<Bool> {
        isDeselectedRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let isDeselectedRelay = BehaviorRelay<Bool>(value: false)
    private let historicalFiatPriceService: HistoricalFiatPriceServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(cryptoCurrency: CryptoCurrency,
         fiatCurrency: FiatCurrency,
         historicalFiatPriceService: HistoricalFiatPriceServiceAPI,
         lineChartView: LineChartView) {
        self.historicalFiatPriceService = historicalFiatPriceService
        self.lineChartInteractor = AssetLineChartInteractor(cryptoCurrency: cryptoCurrency, fiatCurrency: fiatCurrency)
        self.lineChartUserInteractor = AssetLineChartUserInteractor(chartView: lineChartView)
        self.assetPriceViewInteractor = InstantAssetPriceViewInteractor(
            historicalPriceProvider: historicalFiatPriceService,
            chartUserInteracting: lineChartUserInteractor
        )

        lineChartUserInteractor
            .state
            .map { $0 == .deselected }
            .bind(to: isDeselectedRelay)
            .disposed(by: disposeBag)
        
        /// Bind window relay to the `PublishRelay<PriceWindow>` on
        /// both the `AssetLineChartInteractor` and the `HistoricalFiatPriceService`.
        window
            .bind(to: lineChartInteractor.priceWindowRelay)
            .disposed(by: disposeBag)
        
        window
            .bind(to: historicalFiatPriceService.fetchTriggerRelay)
            .disposed(by: disposeBag)
    }
    
}
