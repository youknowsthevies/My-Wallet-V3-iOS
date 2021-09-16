// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import PlatformKit
import RxRelay
import RxSwift

/// Implementation of `AssetPriceViewInteracting` that streams a State for the daily asset price/change.
public final class AssetPriceViewDailyInteractor: AssetPriceViewInteracting {

    public var state: Observable<DashboardAsset.State.AssetPrice.Interaction> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                refreshRelay
            )
            .map(\.0)
            .flatMapLatest(weak: self) { (self, fiatCurrency) in
                self.fetch(fiatCurrency: fiatCurrency).asObservable()
            }
            .map(DashboardAsset.State.AssetPrice.Interaction.loaded)
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let cryptoCurrency: CryptoCurrency
    private let priceService: PriceServiceAPI
    private let stateRelay = BehaviorRelay<DashboardAsset.State.AssetPrice.Interaction>(value: .loading)
    private let disposeBag = DisposeBag()
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let refreshRelay = PublishRelay<Void>()

    // MARK: - Setup

    public init(
        cryptoCurrency: CryptoCurrency,
        priceService: PriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
    }

    // MARK: - Public Functions

    public func refresh() {
        refreshRelay.accept(())
    }

    private func fetch(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<DashboardAsset.Value.Interaction.AssetPrice, Error> {
        priceService.price(of: cryptoCurrency, in: fiatCurrency)
            .combineLatest(priceService.price(of: cryptoCurrency, in: fiatCurrency, at: .oneDay))
            .tryMap { currentBalance, previousBalance -> DashboardAsset.Value.Interaction.AssetPrice in
                let percentage: Decimal // in range [0...1]
                let change = try currentBalance.moneyValue - previousBalance.moneyValue
                if currentBalance.moneyValue.isZero {
                    percentage = 0
                } else {
                    // Zero or negative previousBalance shouldn't be possible but
                    // it is handled in any case, in a way that does not throw.
                    if previousBalance.moneyValue.isPositive {
                        percentage = try change.percentage(in: previousBalance.moneyValue)
                    } else {
                        percentage = 0
                    }
                }
                return DashboardAsset.Value.Interaction.AssetPrice(
                    time: .days(1),
                    fiatValue: currentBalance.moneyValue,
                    changePercentage: percentage.doubleValue,
                    fiatChange: change
                )
            }
            .eraseToAnyPublisher()
    }
}
