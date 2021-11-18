// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import RxToolKit
import TestKit
import XCTest

class PublisherTests: XCTestCase {

    private var disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        disposeBag = .init()
    }

    func test_int() {
        let source = (1...100).publisher
        var events = [Event<Int>]()

        source.asObservable()
            .subscribe { events.append($0) }
            .disposed(by: disposeBag)

        XCTAssertEqual(events, (1...100).map(Event.next) + [.completed])
    }

    func test_string() {

        let input = "blockchain.com".map(String.init)
        let source = input.publisher
        var events = [Event<String>]()

        source.asObservable()
            .subscribe { events.append($0) }
            .disposed(by: disposeBag)

        XCTAssertEqual(events, input.map(Event.next) + [.completed])
    }

    func test_failing() {

        enum Test: Error { case error }

        let source = (1...100).publisher
        var events = [Event<Int>]()

        source.setFailureType(to: Test.self)
            .tryMap { i -> Int in
                guard i < 15 else { throw Test.error }
                return i
            }
            .asObservable()
            .subscribe { events.append($0) }
            .disposed(by: disposeBag)

        XCTAssertEqual(events, (1...14).map(Event.next) + [.error(Test.error)])
    }

    func test_concurrency() throws {

        let routes = Set(
            Either.randomRoutes(
                count: 1000,
                in: Array(0...2),
                and: "abcd".map(String.init),
                bias: 0.1,
                length: 5...7
            )
            .compactMap(\.first)
        )

        let subjects = Dictionary(
            uniqueKeysWithValues: routes.map { route in
                (route, PublishSubject<Either<Int, String>>())
            }
        )

        var actual: Set<Either<Int, String>> = []

        for (i, route) in routes.enumerated() {
            let e = expectation(description: "\(i)")
            subjects[route]?
                .asPublisher()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { result in
                        actual.insert(result)
                        e.fulfill()
                    }
                )
                .teardown(in: self)
        }

        let q = (1...4).map { i in
            DispatchQueue(label: "q[\(i)]", attributes: .concurrent)
        }

        for (i, route) in routes.enumerated() {
            q[i % q.count].asyncAfter(deadline: .now() + .random(in: 0...0.01)) {
                subjects[route]?.on(.next(route))
            }
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(routes, actual)
    }
}
