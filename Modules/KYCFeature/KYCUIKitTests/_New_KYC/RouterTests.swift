// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import KYCUIKit
import PlatformUIKit
import SwiftUI
import XCTest

final class RouterTests: XCTestCase {

    private var router: KYCUIKit.Router!
    private var mockExternalAppOpener: MockExternalAppOpener!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockExternalAppOpener = MockExternalAppOpener()
        router = .init(emailVerificationService: MockEmailVerificationService(), openMailApp: mockExternalAppOpener.openMailApp)
    }

    override func tearDownWithError() throws {
        router = nil
        mockExternalAppOpener = nil
        try super.tearDownWithError()
    }

    func test_routesTo_emailVerification() throws {
        let viewController = MockViewController()
        router.routeToEmailVerification(from: viewController, emailAddress: "test@example.com", flowCompletion: { _ in })
        let presentedViewController = viewController.recordedInvocations.presentViewController.first
        XCTAssertEqual(presentedViewController?.children.count, 1)
        let swiftUIHostingController = presentedViewController?.children.first as? UIHostingController<EmailVerificationView>
        XCTAssertNotNil(swiftUIHostingController)
    }

    func test_calls_back_to_passedIn_completionBlock() throws {
        var didCallCompletionBlock = false
        let environment = router.buildEmailVerificationEnvironment(emailAddress: "test@example.com", flowCompletion: { _ in
            didCallCompletionBlock = true
        })
        environment.flowCompletionCallback?(.completed)
        XCTAssertTrue(didCallCompletionBlock)
    }

    func test_uses_extenalAppOpener_to_openMailApp() throws {
        let environment = router.buildEmailVerificationEnvironment(emailAddress: "test@example.com", flowCompletion: { _ in })
        var valueReceived = false
        let e = expectation(description: "Wait for publisher to send value")
        let cancellable = environment.openMailApp()
            .sink(receiveValue: { value in
                valueReceived = value
                e.fulfill()
            })
        let openMailRequest = mockExternalAppOpener.recordedInvocations.open.first
        XCTAssertEqual(openMailRequest?.url, URL(string: "message://"))
        openMailRequest?.completionHandler(true)
        waitForExpectations(timeout: 3)
        XCTAssertTrue(valueReceived)
        cancellable.cancel()
    }
}
