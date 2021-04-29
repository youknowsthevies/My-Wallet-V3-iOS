// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import RxSwift
import RxTest
@testable import TransactionKit
import XCTest

final class SwapQuotesEngineMock {
    private let service: OrderQuoteServiceAPI
    private let amount = BehaviorSubject<BigInt>(value: .zero)
    private var amountObservable: Observable<BigInt> {
        amount
            .asObservable()
    }
    init(service: OrderQuoteServiceAPI = OrderQuoteServiceMock()) {
        self.service = service
    }
    
    func getRate(direction: OrderDirection = .internal, pair: OrderPair) -> Observable<BigInt> {
        Observable.combineLatest(
            service
                .latestQuote
                .asObservable(),
            amountObservable
        )
        .map { PricesInterpolator(prices: $0.0.quote.priceTiers).rate(amount: $0.1) }
    }
    
    func updateAmount(_ amount: BigInt) {
        self.amount.onNext(amount)
    }
}

final class ExchangeRateTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var subject: SwapQuotesEngineMock!

    override func setUp() {
        super.setUp()

        subject = .init(service: OrderQuoteServiceMock())
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil

        super.tearDown()
    }
    
    func test_btc_bch_rate() throws {
        let expectedRate = BigInt("34936063248847697954")
        subject.updateAmount(BigInt(12345))
        let rateObservable = subject
            .getRate(direction: .internal, pair: .btc_eth)
        let result: TestableObserver<BigInt> = scheduler
            .start { rateObservable }
        let expectedEvents: [Recorded<Event<BigInt>>] = Recorded.events(
            .next(
                200,
                expectedRate
            )
        )
        XCTAssertEqual(result.events, expectedEvents)
    }
}
