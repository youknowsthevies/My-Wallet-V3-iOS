//
//  CachedValueTests.swift
//  ToolKitTests
//
//  Created by Daniel Huri on 21/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxBlocking
import RxRelay
import RxSwift
import RxTest
import XCTest

@testable import ToolKit

final class CachedValueTests: XCTestCase {
    
    private var disposeBag = DisposeBag()
    private var testScheduler: TestScheduler!

    override func setUp() {
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testInitialSubscriptionToValue() {
        let expectedValue = "expected_value"
        let configuration = CachedValueConfigurationOld(refreshType: .onSubscription)
        let cachedValue = CachedValueOld<String>(configuration: configuration)
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
        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValueOld<String>(configuration: configuration)
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
        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValueOld<String>(configuration: configuration)
        cachedValue.setFetch {
            Single.just(expectedResult)
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

        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValueOld<String>(configuration: configuration)
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

        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValueOld<String>(configuration: configuration)

        cachedValue.setFetch {
            Single.just(expectedResult)
        }

        for _ in (0...7) {
            XCTAssertEqual(
                try? cachedValue.valueSingle.toBlocking().first(),
                expectedResult
            )
        }
    }

    func testMixtureOfSubscriptions() {
        
        // Arrange
        
        let expectedResults: [String] = ["expected_result1", "expected_result2", "expected_result3"]
        var index = 0

        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription,
            scheduler: testScheduler
        )
        
        let cachedValue = CachedValueOld<String>(configuration: configuration)

        cachedValue.setFetch { () -> Single<String> in
            let current = expectedResults[index % expectedResults.count]
            index += 1
            return Single.just(current)
        }
        
        // Act
                
        let observer = testScheduler.createObserver(String.self)
        
        cachedValue.valueObservable
            .subscribe(onNext: { element in
                observer.onNext(element)
            })
            .disposed(by: disposeBag)
        
        for _ in 1..<expectedResults.count {
            cachedValue.fetchValue
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        testScheduler.start()
                    
        // Assert
        
        XCTAssertEqual(observer.events.map { $0.value.element! }, expectedResults)
    }

    func testRecoveryFromError() {

        let expectedValue = "result"
        let expectedError = NSError(domain: "test-error", code: 0, userInfo: nil)

        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription,
            scheduler: MainScheduler.instance
        )
        let cachedValue = CachedValueOld<String>(configuration: configuration)

        var result: Result<String, NSError> = .failure(expectedError)

        cachedValue.setFetch { () -> Observable<String> in
            switch result {
            case .failure(let error):
                return Observable.error(error)
            case .success(let element):
                return Observable.just(element)
            }
        }

        let element = cachedValue.valueObservable.toBlocking().materialize()
        
        switch element {
        case .completed(elements: let elements):
            XCTFail("Expected an error to be thrown. Received an element: \(elements) instead")
        case .failed(elements: _, error: let error):
            XCTAssertEqual(error as NSError, CachedValueOld<String>.CacheError.fetchFailed as NSError)
        }

        result = .success(expectedValue)
        do {
            let element = try cachedValue.valueObservable.toBlocking().first()!
            XCTAssertEqual(element, expectedValue)
        } catch {
            XCTFail("Expected a value to be sent - received an error instead")
        }
    }
    
    // MARK: - State Relay Tests (TODO: Add more tests)

    func testStateRelayOnInitialSubscription() throws {
        
        // Arrange
        
        typealias StreamState = CachedValueOld<String>.StreamState
        
        let configuration = CachedValueConfigurationOld(
            refreshType: .onSubscription,
            scheduler: testScheduler
        )
        
        let cachedValue = CachedValueOld<String>(configuration: configuration)
        
        let expectedValue = "expected_value"
        cachedValue.setFetch { Single.just(expectedValue) }
                
        // Act
                
        let observer = testScheduler.createObserver(StreamState.self)
        
        cachedValue.innerState
            .subscribe(onNext: { state in
                observer.onNext(state)
            })
            .disposed(by: disposeBag)
        
        cachedValue.fetchValue
            .subscribe()
            .disposed(by: disposeBag)
                
        testScheduler.start()
                
        // Assert

        let elements = observer.events
            .map { $0.value.element! }
            .map { $0.debugState }
        
        let expectedElements = [
                StreamState.empty,
                StreamState.calculating,
                StreamState.stream(.private(expectedValue))
            ]
            .map { $0.debugState }
        
        XCTAssertEqual(
            elements,
            expectedElements
        )
    }
}

