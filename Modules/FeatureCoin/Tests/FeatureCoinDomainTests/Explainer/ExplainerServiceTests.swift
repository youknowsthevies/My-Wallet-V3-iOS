// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
@testable import FeatureCoinDomain
import XCTest

final class ExplainerServiceTests: XCTestCase {

    var account: Account.Snapshot = .preview.trading

    var app: AppProtocol!
    var sut: ExplainerService!
    var defaults: Mock.UserDefaults!

    override func setUp() {
        super.setUp()
        app = App.test
        defaults = Mock.UserDefaults()
        sut = ExplainerService(app: app, defaults: defaults)
    }

    func test_isAccepted_default() throws {
        XCTAssertFalse(sut.isAccepted(account))
    }

    func test_accept() throws {
        sut.accept(account)
        XCTAssertTrue(sut.isAccepted(account))
        try XCTAssertTrue(isAccepted)
    }

    func test_reset() throws {
        sut.accept(account)
        sut.reset(account)
        XCTAssertFalse(sut.isAccepted(account))
        try XCTAssertFalse(isAccepted)
    }

    func test_resetAll() throws {
        sut.accept(account)
        sut.resetAll()
        XCTAssertFalse(sut.isAccepted(account))
        XCTAssertNil(defaults.store[key])
    }

    private let key = blockchain.ux.asset.account.explainer(\.id)
    private var isAccepted: Bool {
        get throws {
            try XCTUnwrap(defaults.store[key][dotPath: account.accountType.rawValue] as? Bool)
        }
    }
}

extension Mock {

    class UserDefaults: Foundation.UserDefaults {

        var store: [String: Any] = [:]

        override func object(forKey defaultName: String) -> Any? {
            store[defaultName]
        }

        override func set(_ value: Any?, forKey defaultName: String) {
            store[defaultName] = value
        }
    }
}
