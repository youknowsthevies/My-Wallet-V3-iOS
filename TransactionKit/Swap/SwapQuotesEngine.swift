//
//  SwapQuotesEngine.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import PlatformKit
import RxSwift

struct PricedQuote {
    let price: BigInt
    let networkFee: MoneyValue
    let staticFee: MoneyValue
    let sampleDepositAddress: String
}

final class SwapQuotesEngine {
    
    // MARK: - Private Properties

    private let stopSubject = PublishSubject<Void>()
    private let service: OrderQuoteServiceAPI
    private let amount = BehaviorSubject<BigInt>(value: .zero)
    private var amountObservable: Observable<BigInt> {
        amount.asObservable()
    }
    
    // MARK: - Init
    
    init(service: OrderQuoteServiceAPI = resolve()) {
        self.service = service
    }
    
    // MARK: - Public Functions

    func stop() {
        stopSubject.on(.next(()))
    }

    func updateAmount(_ amount: BigInt) {
        self.amount.onNext(amount)
    }

    func getRate(direction: OrderDirection, pair: OrderPair) -> Observable<PricedQuote> {
        Observable.combineLatest(
            quote(direction: direction, pair: pair),
            amountObservable
        )
        .map { (quote, amount) in
            let interpolator = PricesInterpolator(prices: quote.quote.priceTiers)
            return PricedQuote(
                price: interpolator.rate(amount: amount),
                networkFee: quote.networkFee,
                staticFee: quote.staticFee,
                sampleDepositAddress: quote.sampleDepositAddress
            )
        }
        .share(replay: 1, scope: .whileConnected)
    }

    // MARK: - Private Functions

    private func quote(direction: OrderDirection, pair: OrderPair) -> Observable<OrderQuoteResponse> {
        fetchQuote(direction: direction, pair: pair)
            .asObservable()
            .flatMap { quote -> Observable<OrderQuoteResponse> in
                let delay = Int(quote.expiresAt.timeIntervalSince(quote.createdAt))
                return Observable
                    .timer(.seconds(delay), period: .seconds(delay), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                    .flatMap { (_: Int) -> Observable<OrderQuoteResponse> in
                        self.fetchQuote(direction: direction, pair: pair).asObservable()
                    }
                    .startWith(quote)
            }
            .takeUntil(stopSubject)
    }

    private func fetchQuote(direction: OrderDirection, pair: OrderPair) -> Single<OrderQuoteResponse> {
        service
            .fetchQuote(
                direction: direction,
                sourceCurrencyType: pair.sourceCurrencyType,
                destinationCurrencyType: pair.destinationCurrencyType
            )
    }
}
