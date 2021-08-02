// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationUIKit
import ComposableArchitecture
import Localization
import ToolKit
import XCTest

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
                deviceVerificationService: MockDeviceVerificationService(),
                mainQueue: mockMainQueue.eraseToAnyScheduler()
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
        XCTAssertNotNil(state.verifyDeviceState)
        XCTAssertEqual(state.emailAddress, "")
        XCTAssertFalse(state.isEmailValid)
        XCTAssertFalse(state.isVerifyDeviceScreenVisible)
    }

    func test_disappear_will_reset_state() {
        testStore.send(.didDisappear) { state in
            XCTAssertEqual(state.emailAddress, "")
            XCTAssertFalse(state.isEmailValid)
            XCTAssertFalse(state.isVerifyDeviceScreenVisible)
        }
    }

    func test_send_device_verification_email_success() {
        let validEmail = "valid@example.com"
        testStore.assert(
            .send(.didChangeEmailAddress(validEmail)) { state in
                state.emailAddress = validEmail
                state.isEmailValid = true
            },
            .send(.sendDeviceVerificationEmail),
            .do { self.mockMainQueue.advance() },
            .receive(.didSendDeviceVerificationEmail(.success(.noValue))) { state in
                state.verifyDeviceState = .init(emailAddress: validEmail)
            },
            .receive(.setVerifyDeviceScreenVisible(true)) { state in
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
