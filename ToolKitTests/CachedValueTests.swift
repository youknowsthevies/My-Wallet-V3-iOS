//
//  CachedValueTests.swift
//  ToolKitTests
//
//  Created by Daniel Huri on 21/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxBlocking
import RxTest

@testable import ToolKit

final class CachedValueTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var scheduler: TestScheduler!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testInitialSubscriptionToValue() {
        let expectedValue = "expected_value"
        let configuration = CachedValueConfiguration(refreshType: .onSubscription)
        let cachedValue = CachedValue<String>(configuration: configuration)
        cachedValue.setFetch { Single.just(expectedValue) }
        do {
            let value = try cachedValue.valueSingle.toBlocking().first()
            XCTAssertEqual(value, expectedValue)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testInitialSubscriptionToValueObservable() {
        let expectedValue = "expected_value"
        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)
        cachedValue.setFetch { Single.just(expectedValue) }
        do {
            let value = try cachedValue.valueObservable.toBlocking().first()
            XCTAssertEqual(value, expectedValue)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testMultipleSubscriptionsToValueObservable() {
        let expectedResult = "expected_result1"
        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)
        cachedValue.setFetch {
            return Single.just(expectedResult)
        }

        for _ in (0...4) {
            XCTAssertEqual(
                try? cachedValue.valueObservable.toBlocking().first(),
                expectedResult
            )
        }
    }

    func testMultipleConsecutiveFetches() {
        let expectedResults: [String] = ["expected_result1", "expected_result2", "expected_result3"]
        var index = 0

        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)
        cachedValue.setFetch { () -> Single<String> in
            let current = expectedResults[index % expectedResults.count]
            index += 1
            return Single.just(current)
        }

        for index in (0...7) {
            XCTAssertEqual(
                try? cachedValue.fetchValue.toBlocking().first(),
                expectedResults[index % expectedResults.count]
            )
        }
    }

    func testsRefreshTypeOnce() {
        let expectedResult = "expected_result1"

        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)

        cachedValue.setFetch {
            return Single.just(expectedResult)
        }

        for _ in (0...7) {
            XCTAssertEqual(
                try? cachedValue.valueSingle.toBlocking().first(),
                expectedResult
            )
        }
    }

    func testMixtureOfSubscriptions() {
        let expectedResults: [String] = ["expected_result1", "expected_result2", "expected_result3"]
        var index = 0

        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)

        cachedValue.setFetch { () -> Single<String> in
            let current = expectedResults[index % expectedResults.count]
            index += 1
            return Single.just(current)
        }

        var result: [String] = []

        // one time
        cachedValue.valueObservable
            .subscribe(
                onNext: { current in
                    result.append(current)
                })
                .disposed(by: disposeBag)

        // 4 times
        for index in 1..<expectedResults.count {
            XCTAssertEqual(
                try? cachedValue.fetchValue.toBlocking().first(),
                expectedResults[index]
            )
        }

        XCTAssertEqual(result, expectedResults)
    }
}

