// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
@testable import PlatformKit
import RxBlocking
import RxRelay
import RxSwift
import RxTest
import ToolKit
import XCTest

class CustodialMoneyBalanceFetcherTests: XCTestCase {

    let currency: CryptoCurrency = .bitcoin
    var api: TradingBalanceServiceAPIMock!
    var sut: CustodialBalanceStatesFetcherAPI!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!

    override func setUp() {

        disposeBag = DisposeBag()
        /// TestScheduler with `0.001` resolution (milliseconds)
        scheduler = TestScheduler(initialClock: 0, resolution: 0.001, simulateProcessingDelay: false)
        api = TradingBalanceServiceAPIMock()
        sut = CustodialBalanceStatesFetcher(tradingBalanceService: api, scheduler: scheduler)
        sut.setupIfNeeded()
    }

    override func tearDown() {
        disposeBag = nil
        api = nil
        sut = nil
        scheduler = nil
    }

    // MARK: - Test Funding

    func testValidResponseIsFundedAfterThrottlingTimespan() {
        api.underlyingCustodialBalance = CustodialAccountBalanceStates(
            response: CustodialBalanceResponse(
                balances: [currency.code : .init(pending: "0", pendingDeposit: "0", pendingWithdrawal: "0", available: "2", withdrawable: "2")]
            ),
            enabledCurrenciesService: EnabledCurrenciesService(featureFlagService: InternalFeatureFlagServiceMock())
        )

        let events = obervedIsFundedEvents(times: [50, 100, 150, 200])

        guard events.count == 1 else {
            XCTFail("Expected 1 event")
            return
        }

        let element = events.first!
        guard element.time == 550 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }

        XCTAssertEqual(value, true)
    }

    func testZeroedResponseIsFunded() {
        api.underlyingCustodialBalance = CustodialAccountBalanceStates(
            response: CustodialBalanceResponse(
                balances: [currency.code : .init(pending: "0", pendingDeposit: "0", pendingWithdrawal: "0", available: "0", withdrawable: "0")]
            ),
            enabledCurrenciesService: EnabledCurrenciesService(featureFlagService: InternalFeatureFlagServiceMock())
        )

        let events = obervedIsFundedEvents(times: [20, 30, 40])
        let element = events.first!
        guard element.time == 520 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }

        XCTAssertEqual(value, true)
    }

    func testValidResponseIsFunded() {
        api.underlyingCustodialBalance = CustodialAccountBalanceStates(
            response: CustodialBalanceResponse(
                balances: [currency.code : .init(pending: "0", pendingDeposit: "0", pendingWithdrawal: "0", available: "1", withdrawable: "1")]
            ),
            enabledCurrenciesService: EnabledCurrenciesService(featureFlagService: InternalFeatureFlagServiceMock())
        )

        let events = obervedIsFundedEvents(times: [20, 30, 40])
        let element = events.first!
        guard element.time == 520 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }
        XCTAssertEqual(value, true)
    }

    func testNilResponseIsFunded() {
        api.underlyingCustodialBalance = .absent
        let events = obervedIsFundedEvents(times: [20, 30, 80])

        let element = events.first!
        guard element.time == 520 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }
        XCTAssertEqual(value, false)
    }

    // MARK: - Helper methods

    private func obervedIsFundedEvents(times: [Int])  -> [Recorded<Event<Bool>>] {
        let observer = scheduler.createObserver(Bool.self)

        scheduler
            .createHotObservable(times.map { .next($0, ()) })
            .bindAndCatch(to: sut.balanceFetchTriggerRelay)
            .disposed(by: disposeBag)

        scheduler.start()

        sut.isFunded
            .bindAndCatch(to: observer)
            .disposed(by: disposeBag)

        return observer.events
    }

    // MARK: - Test Balance

    func testNilResponseBalance() {
        api.underlyingCustodialBalance = .absent
        let response = CustodialBalanceResponse(balances: [:])
        let events = observedBalanceEvents(
            data: [(20, response)]
        )
        let expectedStates = CustodialAccountBalanceStates()
        let element = events.first!
        guard element.time == 20 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }
        XCTAssertEqual(value, expectedStates)
    }

    func testZeroedResponse() {
        api.underlyingCustodialBalance = .absent

        let response = CustodialBalanceResponse(
            balances: [
                currency.code : .init(
                    pending: "0",
                    pendingDeposit: "0",
                    pendingWithdrawal: "0",
                    available: "0",
                    withdrawable: "0"
                )
            ]
        )

        let events = observedBalanceEvents(
            data: [(20, response)]
        )
        var expectedStates = CustodialAccountBalanceStates()
        expectedStates[.crypto(currency)] = CustodialAccountBalanceState.present(
            CustodialAccountBalance(currency: .crypto(currency), response: response[.crypto(currency)]!)
        )

        let element = events.first!
        guard element.time == 20 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }
        XCTAssertEqual(value, expectedStates)
    }

    func testValidResponse() {
        api.underlyingCustodialBalance = .absent

        let response = CustodialBalanceResponse(balances: [
            currency.code: .init(
                pending: "0",
                pendingDeposit: "0",
                pendingWithdrawal: "0",
                available: "10",
                withdrawable: "10"
            )
        ]
        )

        let events = observedBalanceEvents(data: [(40, response)])
        var expectedStates = CustodialAccountBalanceStates()
        expectedStates[.crypto(currency)] = CustodialAccountBalanceState.present(
            CustodialAccountBalance(currency: .crypto(currency), response: response[.crypto(currency)]!)
        )

        let element = events.first!
        guard element.time == 40 else {
            XCTFail("Expected certain time")
            return
        }

        guard case Event.next(let value) = element.value else {
            XCTFail("Expected next event")
            return
        }
        XCTAssertEqual(value, expectedStates)
    }

    class InternalFeatureFlagServiceMock: InternalFeatureFlagServiceAPI {
        func isEnabled(_ feature: InternalFeature) -> Bool {
            false
        }
        func enable(_ feature: InternalFeature) { }
        func enable(_ features: [InternalFeature]) { }
        func disable(_ feature: InternalFeature) { }
    }

    private func observedBalanceEvents(data: [(refresh: Int,
                                              response: CustodialBalanceResponse)]) -> [Recorded<Event<CustodialAccountBalanceStates>>] {
        let observer = scheduler.createObserver(CustodialAccountBalanceStates.self)

        for item in data {
            scheduler.scheduleAt(item.refresh - 1) { [unowned self] in
                self.api.underlyingCustodialBalance = CustodialAccountBalanceStates(
                    response: item.response,
                    enabledCurrenciesService: EnabledCurrenciesService(featureFlagService: InternalFeatureFlagServiceMock())
                )
            }
        }

        scheduler
            .createHotObservable(data.map { .next($0.refresh, ()) })
            .bindAndCatch(to: sut.balanceFetchTriggerRelay)
            .disposed(by: disposeBag)

        scheduler.start()

        sut.balanceStatesObservable
            .bindAndCatch(to: observer)
            .disposed(by: disposeBag)

        return observer.events
    }

}
