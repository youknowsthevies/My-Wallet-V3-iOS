//
//  AssetLineChartTableViewCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/13/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit
import RxCocoa
import PlatformKit
import Charts

final class AssetLineChartTableViewCellPresenter: AssetLineChartTableViewCellPresenting {
    
    // MARK: - AssetLineChartTableViewCellPresenting
    
    var priceWindowPresenter: MultiActionViewPresenting {
        return DefaultActionViewPresenter(using: priceWindowItems)
    }
    
    let presenterContainer: AssetLineChartPresenterContainer
    
    let lineChartView: LineChartView
    
    var isScrollEnabled: Driver<Bool> {
        return scrollingEnabledRelay.asDriver()
    }
    
    var window: Signal<PriceWindow> {
        return windowRelay.asSignal()
    }
    
    // MARK: - Private Properties
    
    private let scrollingEnabledRelay = BehaviorRelay(value: false)
    private let interactor: AssetLineChartTableViewCellInteracting
    private let cryptoCurrency: CryptoCurrency
    private let windowRelay = PublishRelay<PriceWindow>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(cryptoCurrency: CryptoCurrency,
         fiatCurrency: FiatCurrency,
         historicalFiatPriceService: HistoricalFiatPriceServiceAPI) {
        self.cryptoCurrency = cryptoCurrency
        
        /// Setup `lineChartView`
        self.lineChartView = LineChartView()
        lineChartView.chartDescription?.enabled = false
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.gridBackgroundColor = .clear
        lineChartView.borderColor = .clear
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.minOffset = 0.0
        lineChartView.legend.enabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.data = LineChartData.empty
        
        self.interactor = AssetLineChartTableViewCellInteractor(
            cryptoCurrency: cryptoCurrency,
            fiatCurrency: fiatCurrency,
            historicalFiatPriceService: historicalFiatPriceService,
            lineChartView: lineChartView
        )
        
        self.presenterContainer = .init(
            priceViewPresenter: AssetPriceViewPresenter(
                interactor: interactor.assetPriceViewInteractor,
                alignment: .center,
                descriptors: .assetPrice(
                    accessibilityIdSuffix: cryptoCurrency.displayCode,
                    priceFontSize: 32.0,
                    changeFontSize: 14.0
                )
            ),
            lineChartPresenter: .init(edge: 0.0, interactor: interactor.lineChartInteractor),
            lineChartView: lineChartView
        )
        
        interactor
            .isDeselected
            .drive(scrollingEnabledRelay)
            .disposed(by: disposeBag)
        
        windowRelay
            .bind(to: interactor.window)
            .disposed(by: disposeBag)
    }
    
    private func setup() {
        window
            .emit(onNext: { [weak self] priceWindow in
                guard let self = self else { return }
                self.windowRelay.accept(priceWindow)
            })
            .disposed(by: disposeBag)
    }
    
    private lazy var priceWindowItems: [SegmentedViewModel.Item] = {
        [
            .text(LocalizationConstants.DashboardDetails.day,
                  action: { [weak self] in
                    guard let self = self else { return }
                    self.windowRelay.accept(.day(.fifteenMinutes))
                }
            ),
            .text(LocalizationConstants.DashboardDetails.week,
                  action: { [weak self] in
                    guard let self = self else { return }
                    self.windowRelay.accept(.week(.oneHour))
            }),
            .text(LocalizationConstants.DashboardDetails.month,
                  action: { [weak self] in
                    guard let self = self else { return }
                    self.windowRelay.accept(.month(.twoHours))
                }
            ),
            .text(LocalizationConstants.DashboardDetails.year,
                  action: { [weak self] in
                    guard let self = self else { return }
                    self.windowRelay.accept(.year(.oneDay))
            }),
            .text(LocalizationConstants.DashboardDetails.all,
                  action: { [weak self] in
                    guard let self = self else { return }
                    self.windowRelay.accept(.all(.fiveDays))
            })
        ]
    }()
}
