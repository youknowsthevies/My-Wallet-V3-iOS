// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import TestKit
import ToolKit
import ToolKitMock
@testable import WalletPayloadKit
import XCTest

class WalletUpgradeJSServiceTests: XCTestCase {

    var contextProvider: MockContextProvider!
    var sut: WalletUpgradeJSServicing!

    override func setUp() {
        super.setUp()
        contextProvider = MockContextProvider()
        sut = WalletUpgradeJSService(contextProvider: contextProvider, queue: .main)
    }

    override func tearDown() {
        sut = nil
        contextProvider = nil
        super.tearDown()
    }

    private func newContext(script: String) -> JSContext {
        let context = JSContext()
        context?.evaluateScript(script)
        return context!
    }

    private var successScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_success();
        };
        """
    }

    private var multipleSuccessScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_success();
            objc_upgrade_V3_success();
        };
        """
    }

    private var successErrorScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_success();
            objc_upgrade_V3_error();
        };
        """
    }

    private var failureScript: String {
        """
        var MyWalletPhone = {};
        MyWalletPhone.upgradeToV3 = function(firstAccountName) {
            objc_upgrade_V3_error();
        };
        """
    }

    func testSuccess() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: successScript)
        let expectedString = "V3"
        let publisher = sut.upgradeToV3()

        // Act + Assert
        XCTAssertPublisherValues(publisher, [expectedString])
    }

    func testSuccessIsInvokedOnlyOnce() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: multipleSuccessScript)
        let expectedString = "V3"
        let publisher = sut.upgradeToV3()

        // Act + Assert
        XCTAssertPublisherValues(publisher, [expectedString])
    }

    func testCompletesAfterFirstSuccess() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: successErrorScript)
        let expectedString = "V3"
        let upgradePublisher = sut.upgradeToV3()

        // Act + Assert
        XCTAssertPublisherValues(upgradePublisher, [expectedString])
    }

    func testError() {
        // Arrange
        contextProvider.underlyingContext = newContext(script: failureScript)
        let upgradePublisher = sut.upgradeToV3()

        // Act + Assert
        XCTAssertPublisherError(upgradePublisher, WalletUpgradeJSError.failedV3Upgrade)
    }
}
