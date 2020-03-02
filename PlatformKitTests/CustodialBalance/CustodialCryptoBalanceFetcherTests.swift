//
//  CustodialCryptoBalanceFetcherTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
import RxSwift
import RxRelay
import RxBlocking
import RxTest
import XCTest

class CustodialCryptoBalanceFetcherTests: XCTestCase {

    let currency: CryptoCurrency = .bitcoin
    var api: CustodialBalanceServiceAPIMock!
    var sut: CustodialAccountBalanceFetching!
    var provider: SimpleBuyServiceProviderAPIMock!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!

    override func setUp() {
        disposeBag = DisposeBag()
        /// TestScheduler with `0.001` resolution (milliseconds)
        scheduler = TestScheduler(initialClock: 0, resolution: 0.001, simulateProcessingDelay: false)
        provider = SimpleBuyServiceProviderAPIMock()
        api = CustodialBalanceServiceAPIMock()
        sut = CustodialCryptoBalanceFetcher(currencyType: currency, service: api, scheduler: scheduler)
    }

    override func tearDown() {
        disposeBag = nil
        provider = nil
        api = nil
        sut = nil
        scheduler = nil
    }

    func testNilResponseIsFunded() {
        api.underlyingCustodialBalance = .absent
        let events = obervedIsFundedEvents()
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(1, false),
            .completed(1)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testZeroedResponseIsFunded() {
        api.underlyingCustodialBalance = .present(CustodialBalance(currency: currency, response: .init(available: "0", pending: "0")))
        let events = obervedIsFundedEvents()
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .completed(1)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testValidResponseIsFunded() {
        api.underlyingCustodialBalance = .present(CustodialBalance(currency: currency, response: .init(available: "1", pending: "2")))
        let events = obervedIsFundedEvents()
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .completed(1)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testNilResponseBalance() {
        api.underlyingCustodialBalance = .absent
        let events = obervedCryptoValueEvents(for: sut.balance.asObservable())
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(1, CryptoValue.zero(assetType: currency)),
            .completed(1)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testNilResponseBalanceObservable() {
        api.underlyingCustodialBalance = .absent
        let events = obervedCryptoValueEvents(for: sut.balanceObservable)
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(1, CryptoValue.zero(assetType: currency)),
            .next(101, CryptoValue.createFromMinorValue("99999", assetType: currency)!)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testZeroedResponse() {
        api.underlyingCustodialBalance = .present(CustodialBalance(currency: currency, response: .init(available: "0", pending: "0")))
        let events = obervedCryptoValueEvents(for: sut.balance.asObservable())
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(1, CryptoValue.zero(assetType: currency)),
            .completed(1)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testValidResponse() {
        api.underlyingCustodialBalance = .present(CustodialBalance(currency: currency, response: .init(available: "1", pending: "2")))
        let events = obervedCryptoValueEvents(for: sut.balance.asObservable())
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(1, CryptoValue.createFromMinorValue("1", assetType: currency)),
            .completed(1)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    // MARK: - Helper methods

    func obervedIsFundedEvents()  -> [Recorded<Event<Bool>>] {
        let minorValue = "99999"
        let laterBalance = CustodialBalance(currency: currency, response: .init(available: minorValue, pending: minorValue))

        let observer: TestableObserver<Bool> = scheduler.createObserver(Bool.self)

        sut.isFunded
            .asObservable()
            .bind(to: observer)
            .disposed(by: disposeBag)

        scheduler.scheduleAt(30, action: { [unowned self] in
            self.api.underlyingCustodialBalance = .present(laterBalance)
        })

        scheduler
            .createColdObservable([.next(1, ()),
                                   .next(99, ()),
                                   .next(100, ())])
            .bind(to: sut.balanceFetchTriggerRelay)
            .disposed(by: disposeBag)

        scheduler.start()

        return observer.events
    }

    func obervedCryptoValueEvents(for observable: Observable<CryptoValue>)  -> [Recorded<Event<CryptoValue>>] {
        let minorValue = "99999"
        let laterBalance = CustodialBalance(currency: currency, response: .init(available: minorValue, pending: minorValue))

        let observer: TestableObserver<CryptoValue> = scheduler.createObserver(CryptoValue.self)

        observable
            .bind(to: observer)
            .disposed(by: disposeBag)

        scheduler.scheduleAt(30, action: { [unowned self] in
            self.api.underlyingCustodialBalance = .present(laterBalance)
        })

        scheduler
            .createColdObservable([.next(1, ()),
                                   .next(99, ()),
                                   .next(100, ())])
            .bind(to: sut.balanceFetchTriggerRelay)
            .disposed(by: disposeBag)

        scheduler.start()

        return observer.events
    }
}
