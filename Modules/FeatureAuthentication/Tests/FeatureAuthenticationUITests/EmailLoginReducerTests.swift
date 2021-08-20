// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureAuthenticationUI
import Localization
import ToolKit
import XCTest

// Mocks
@testable import AnalyticsKitMock
@testable import FeatureAuthenticationMock
@testable import ToolKitMock

final class EmailLoginReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        EmailLoginState,
        EmailLoginState,
        EmailLoginAction,
        EmailLoginAction,
        EmailLoginEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(),
            reducer: emailLoginReducer,
            environment: .init(
                sessionTokenService: MockSessionTokenService(),
                deviceVerificationService: MockDeviceVerificationService(),
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                errorRecorder: MockErrorRecorder(),
                analyticsRecorder: MockAnalyticsRecorder()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = EmailLoginState()
        XCTAssertNil(state.verifyDeviceState)
        XCTAssertEqual(state.emailAddress, "")
        XCTAssertFalse(state.isEmailValid)
        XCTAssertFalse(state.isVerifyDeviceScreenVisible)
    }

    func test_on_appear_should_setup_session_token() {
        testStore.assert(
            .send(.onAppear),
            .receive(.setupSessionToken),
            .do { self.mockMainQueue.advance() },
            .receive(.none)
        )
    }

    func test_send_device_verification_email_success() {
        let validEmail = "valid@example.com"
        testStore.assert(
            .send(.didChangeEmailAddress(validEmail)) { state in
                state.emailAddress = validEmail
                state.isEmailValid = true
            },
            .send(.sendDeviceVerificationEmail) { state in
                state.isLoading = true
                state.verifyDeviceState?.sendEmailButtonIsLoading = true
            },
            .do { self.mockMainQueue.advance() },
            .receive(.didSendDeviceVerificationEmail(.success(.noValue))) { state in
                state.verifyDeviceState = .init(emailAddress: validEmail)
                state.isLoading = false
                state.verifyDeviceState?.sendEmailButtonIsLoading = false
            },
            .receive(.setVerifyDeviceScreenVisible(true)) { state in
                XCTAssertNotNil(state.verifyDeviceState)
                state.verifyDeviceState?.emailAddress = validEmail
                state.isVerifyDeviceScreenVisible = true
            }
        )
    }
    // TODO: Comment for now (wait until error states design are finalised)
//    func test_send_device_verification_email_failure() {
//        testStore.assert(
//            // should still go to verify device screen if it is a network error
//            .send(.didSendDeviceVerificationEmail(.failure(.networkError(.authentication(MockError.unknown))))),
//            .receive(.setVerifyDeviceScreenVisible(true)) { state in
//                state.isVerifyDeviceScreenVisible = true
//            },
//
//            // should not go to verify device screen if it is a missing session token error
//            .send(.didSendDeviceVerificationEmail(.failure(.missingSessionToken))),
//            .receive(.emailLoginFailureAlert(.show(title: "", message: ""))) { state in
//                state.emailLoginFailureAlert = AlertState(
//                    title: TextState(""),
//                    message: TextState(""),
//                    dismissButton: .default(
//                        TextState(LocalizationConstants.okString),
//                        send: .emailLoginFailureAlert(.dismiss)
//                    )
//                )
//            },
//
//            // should not go to verify device screen if it is a recaptcha error
//            .send(.didSendDeviceVerificationEmail(.failure(.recaptchaError(.unknownError)))),
//            .receive(.emailLoginFailureAlert(.show(title: "", message: ""))) { state in
//                state.emailLoginFailureAlert = AlertState(
//                    title: TextState(""),
//                    message: TextState(""),
//                    dismissButton: .default(
//                        TextState(LocalizationConstants.okString),
//                        send: .emailLoginFailureAlert(.dismiss)
//                    )
//                )
//            }
//        )
//    }
}
