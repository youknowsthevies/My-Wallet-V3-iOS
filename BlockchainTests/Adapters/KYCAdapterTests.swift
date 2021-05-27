// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
@testable import KYCKit
@testable import KYCUIKit
import PlatformUIKit // sadly, the transactions logic is here
import SwiftUI
import XCTest

final class KYCAdapterTests: XCTestCase {

    private var adapter: KYCAdapter!
    private var mockRouter: MockKYCRouter!
    private var mockEmailVerificationService: MockEmailVerificationService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockRouter = MockKYCRouter()
        mockEmailVerificationService = MockEmailVerificationService()
        adapter = KYCAdapter(
            router: mockRouter,
            emailVerificationService: mockEmailVerificationService
        )
    }

    override func tearDownWithError() throws {
        adapter = nil
        mockRouter = nil
        mockEmailVerificationService = nil

        try super.tearDownWithError()
    }

    func test_fails_when_emailVerification_fails() throws {
        // GIVEN: The user's email adddress verification check fails
        let e = expectation(description: "Waiting for publisher")
        mockEmailVerificationService.stubbedResults.checkEmailVerificationStatus = .failure(.unknown(MockError.unknown))

        // WHEN: The adapter is asked to present the kyc flow if needed
        let mockViewController = MockViewController()
        var error: KYCRouterError?
        let cancellable = adapter.presentEmailVerificationAndKYCIfNeeded(from: mockViewController).sink(
            receiveCompletion: { completion in
                if case let .failure(theError) = completion {
                    error = theError
                }
                e.fulfill()
            },
            receiveValue: { _ in
                // no-op
            }
        )
        waitForExpectations(timeout: 1)
        cancellable.cancel()

        // THEN: a meaningful error is returned
        XCTAssertEqual(error, .emailVerificationFailed)
    }

    func test_presents_emailVerificationFlow_when_email_unverfied() throws {
        // GIVEN: The user's email adddress is NOT verified
        let e = expectation(description: "Waiting for publisher")
        mockEmailVerificationService.stubbedResults.checkEmailVerificationStatus = .just(
            .init(emailAddress: "test@example.com", status: .unverified)
        )

        // WHEN: The adapter is asked to present the kyc flow if needed
        let mockViewController = MockViewController()
        let cancellable = adapter.presentEmailVerificationAndKYCIfNeeded(from: mockViewController).sink(
            receiveCompletion: { _ in
                e.fulfill()
            },
            receiveValue: { _ in
                // no-op
            }
        )
        // NOTE: The publisher doesn't complete until email verification and subsequent steps are complete
        DispatchQueue.main.asyncAfter(deadline: .now()) { // NOTE: need to dispatch to give time to email verification check publisher to be mapped
            // complete email verification, if it was presented, so the publisher moves to the next step
            self.mockRouter.recordedInvocations.routeToEmailVerification.first?.flowCompletion(.completed)
        }
        waitForExpectations(timeout: 1)
        cancellable.cancel()

        // THEN: the email verification flow is presented
        XCTAssertNotNil(mockRouter.recordedInvocations.routeToEmailVerification.first)
    }

    func test_doesNotPresent_emailVerificationFlow_when_email_verfied() throws {
        // GIVEN: The user's email adddress is verified
        let e = expectation(description: "Waiting for publisher")
        mockEmailVerificationService.stubbedResults.checkEmailVerificationStatus = .just(
            .init(emailAddress: "test@example.com", status: .verified)
        )

        // WHEN: The adapter is asked to present the kyc flow if needed
        let mockViewController = MockViewController()
        let cancellable = adapter.presentEmailVerificationAndKYCIfNeeded(from: mockViewController).sink(
            receiveCompletion: { _ in
                e.fulfill()
            },
            receiveValue: { _ in
                // no-op
            }
        )
        waitForExpectations(timeout: 1)

        // THEN: the email verification flow is not presented
        XCTAssertNil(mockRouter.recordedInvocations.routeToEmailVerification.first)
        cancellable.cancel()
    }
}
