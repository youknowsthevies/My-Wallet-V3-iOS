// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift
import ToolKit

/// This protocol defines a `Single<FiatValue>`. It's the
/// latest Fiat price for a given asset type and is to be used
/// with the `HistoricalPricesAPI`. Basically it's the last item
/// in the array of prices returned.
public protocol LatestFiatPriceFetching: AnyObject {
    var latestPrice: Observable<FiatValue> { get }
}

public protocol HistoricalFiatPriceServiceAPI: LatestFiatPriceFetching {

    /// The calculationState of the service. Returns a `ValueCalculationState` that
    /// contains `HistoricalPriceSeries` and a `FiatValue` each derived from `LatestFiatPriceFetching`
    /// and `HistoricalFiatPriceFetching`.
    var calculationState: Observable<ValueCalculationState<HistoricalFiatPriceResponse>> { get }
    /// A trigger that force the service to fetch the updated price.
    /// Handy to call on currency type and value changes
    var fetchTriggerRelay: PublishRelay<PriceWindow> { get }
}

public final class HistoricalFiatPriceService: HistoricalFiatPriceServiceAPI {

    // MARK: Types

    public typealias CalculationState = ValueCalculationState<HistoricalFiatPriceResponse>

    // MARK: - HistoricalFiatPriceServiceAPI

    public let fetchTriggerRelay = PublishRelay<PriceWindow>()

    public var calculationState: Observable<CalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    // MARK: - LatestFiatPriceFetching

    public var latestPrice: Observable<FiatValue> {
        exchangeAPI.fiatPrice
    }

    // MARK: - Private Properties

    private let calculationStateRelay = BehaviorRelay<CalculationState>(value: .calculating)
    private let bag = DisposeBag()

    // MARK: - Services

    /// The historical price service
    private let priceService: PriceServiceAPI

    /// The exchange service
    private let exchangeAPI: PairExchangeServiceAPI

    /// The currency service
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    /// The associated asset
    private let cryptoCurrency: CryptoCurrency

    private let scheduler: SchedulerType

    private lazy var setup: Void = {
        let historicalPrices: Observable<(HistoricalPriceSeries, PriceWindow)> = Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                fetchTriggerRelay.startWith(.day(.oneHour))
            )
            .throttle(.milliseconds(100), scheduler: scheduler)
            .flatMapLatest { [priceService, cryptoCurrency] fiatCurrency, window
                -> Observable<(HistoricalPriceSeries, PriceWindow)> in
                let prices = priceService.priceSeries(
                    of: cryptoCurrency,
                    in: fiatCurrency,
                    within: window
                )
                return Observable
                    .zip(prices.asObservable(), Observable.just(window))
            }
            .subscribeOn(scheduler)
            .observeOn(scheduler)

        Observable
            .combineLatest(latestPrice, historicalPrices)
            .map { latestPrice, historicalPrices -> HistoricalFiatPriceResponse in
                let (priceSeries, priceWindow) = historicalPrices
                return HistoricalFiatPriceResponse(
                    prices: priceSeries,
                    fiatValue: latestPrice,
                    priceWindow: priceWindow
                )
            }
            .map(CalculationState.value)
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: bag)
    }()

    public init(
        cryptoCurrency: CryptoCurrency,
        exchangeAPI: PairExchangeServiceAPI,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI,
        scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)
    ) {
        self.scheduler = scheduler
        self.exchangeAPI = exchangeAPI
        self.cryptoCurrency = cryptoCurrency
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
    }
}
