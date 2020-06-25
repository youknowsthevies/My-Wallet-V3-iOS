//
//  CustodialCryptoBalanceFetcherTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
import RxBlocking
import RxRelay
import RxSwift
import RxTest
import XCTest

class CustodialCryptoBalanceFetcherTests: XCTestCase {

    let currency: CryptoCurrency = .bitcoin
    var api: TradingBalanceServiceAPIMock!
    var sut: CustodialAccountBalanceFetching!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!

    override func setUp() {
        disposeBag = DisposeBag()
        /// TestScheduler with `0.001` resolution (milliseconds)
        scheduler = TestScheduler(initialClock: 0, resolution: 0.001, simulateProcessingDelay: false)
        api = TradingBalanceServiceAPIMock()
        sut = CustodialCryptoBalanceFetcher(currencyType: currency, service: api, scheduler: scheduler)
    }

    override func tearDown() {
        disposeBag = nil
        api = nil
        sut = nil
        scheduler = nil
    }

    // MARK: - Test Funding
    
    func testValidResponseIsFundedAfterThrottlingTimespan() {
        api.underlyingCustodialBalance = .present(
            TradingAccountBalance(
                currency: currency,
                response: .init(available: "1", pending: "2")
            )
        )
        let events = obervedIsFundedEvents(times: [20, 100, 140, 180])
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(180, true)
        ]
        XCTAssertEqual(events, expectedEvents)
    }
    
    func testZeroedResponseIsFunded() {
        api.underlyingCustodialBalance = .present(
            TradingAccountBalance(
                currency: currency,
                response: .init(available: "0", pending: "0")
            )
        )
        let events = obervedIsFundedEvents(times: [20, 30, 40])
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(40, true)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testValidResponseIsFunded() {
        api.underlyingCustodialBalance = .present(
            TradingAccountBalance(
                currency: currency,
                response: .init(available: "1", pending: "2")
            )
        )
        let events = obervedIsFundedEvents(times: [20, 30, 40])
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(40, true)
        ]
        XCTAssertEqual(events, expectedEvents)
    }
    
    func testNilResponseIsFunded() {
        api.underlyingCustodialBalance = .absent
        let events = obervedIsFundedEvents(times: [20, 30, 80])
        let expectedEvents: [Recorded<Event<Bool>>] = [
            .next(80, false)
        ]
        XCTAssertEqual(events, expectedEvents)
    }
    
    // MARK: - Helper methods

    private func obervedIsFundedEvents(times: [Int])  -> [Recorded<Event<Bool>>] {
        let observer = scheduler.createObserver(Bool.self)
                
        scheduler
            .createHotObservable(times.map { .next($0, ()) })
            .bind(to: sut.balanceFetchTriggerRelay)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        sut.isFunded
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        return observer.events
    }
    
    // MARK: - Test Balance
        
    func testNilResponseBalance() {
        api.underlyingCustodialBalance = .absent
        let events = obervedBalanceEvents(
            data: [
                (20, .absent)
            ]
        )
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(20, CryptoValue.zero(assetType: .bitcoin))
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testZeroedResponse() {
        api.underlyingCustodialBalance = .absent
        let events = obervedBalanceEvents(
            data: [
                (20, .present(
                        .init(
                            currency: .bitcoin,
                            response: .init(available: "0", pending: "0")
                        )
                    )
                )
            ]
        )
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(20, CryptoValue(minor: "0", cryptoCurreny: .bitcoin)!)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    func testValidResponse() {
        api.underlyingCustodialBalance = .absent
        let events = obervedBalanceEvents(
            data: [
                (40, .present(
                        .init(
                            currency: .bitcoin,
                            response: .init(available: "10", pending: "0")
                        )
                    )
                )
            ]
        )
        let expectedEvents: [Recorded<Event<CryptoValue>>] = [
            .next(40, CryptoValue(minor: "10", cryptoCurreny: .bitcoin)!)
        ]
        XCTAssertEqual(events, expectedEvents)
    }

    private func obervedBalanceEvents(data: [(refresh: Int, state: AccountBalanceState<TradingAccountBalance>)])  -> [Recorded<Event<CryptoValue>>] {
        let observer = scheduler.createObserver(CryptoValue.self)
    
        for item in data {
            scheduler.scheduleAt(item.refresh - 1) { [unowned self] in
                self.api.underlyingCustodialBalance = item.state
            }
        }

        scheduler
            .createHotObservable(data.map { .next($0.refresh, ()) })
            .bind(to: sut.balanceFetchTriggerRelay)
            .disposed(by: disposeBag)

        scheduler.start()

        sut.balanceObservable
            .bind(to: observer)
            .disposed(by: disposeBag)

        return observer.events
    }

}
