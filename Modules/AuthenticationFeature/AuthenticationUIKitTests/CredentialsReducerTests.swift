// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
@testable import AuthenticationUIKit
import ComposableArchitecture
import Localization
import ToolKit
import XCTest

final class CredentialsReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var mockPollingQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        CredentialsState,
        CredentialsState,
        CredentialsAction,
        CredentialsAction,
        CredentialsEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        mockPollingQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(),
            reducer: credentialsReducer,
            environment: .init(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                pollingQueue: mockPollingQueue.eraseToAnyScheduler(),
                deviceVerificationService: MockDeviceVerificationService(),
                emailAuthorizationService: MockEmailAuthorizationService(),
                sessionTokenService: MockSessionTokenService(),
                smsService: MockSMSService(),
                loginService: MockLoginService(),
                wallet: MockWalletAuthenticationKitWrapper(),
                analyticsRecorder: MockAnalyticsRecorder(),
                errorRecorder: NoOpErrorRecorder()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        mockPollingQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = CredentialsState()
        XCTAssertNotNil(state.passwordState)
        XCTAssertNotNil(state.twoFAState)
        XCTAssertNotNil(state.hardwareKeyState)
        XCTAssertEqual(state.emailAddress, "")
        XCTAssertEqual(state.walletGuid, "")
        XCTAssertEqual(state.emailCode, "")
        XCTAssertFalse(state.isTwoFACodeOrHardwareKeyVerified)
        XCTAssertFalse(state.isAccountLocked)
    }

    func test_did_appear_should_set_wallet_info() {
        let mockWalletInfo = MockDeviceVerificationService.mockWalletInfo
        testStore.assert(
            .send(.didAppear(walletInfo: mockWalletInfo)) { state in
                state.emailAddress = mockWalletInfo.email
                state.walletGuid = mockWalletInfo.guid
                state.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.setupSessionToken)),
            .do { self.mockMainQueue.advance() },
            .receive(.none)
        )
    }

    // MARK: - Wallet Pairing Actions

    func test_authenticate_success_should_update_view_state_and_decrypt_password() {

        // some preliminery actions
        setupWalletInfoAndSessionToken()

        testStore.assert(
            // authentication without 2FA
            .send(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.decryptWalletWithPassword("")))
        )
    }

    func test_authenticate_email_required_should_return_relevant_actions() {
        // set email authorization as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .email

        // some preliminery actions
        setupWalletInfoAndSessionToken()

        testStore.assert(
            // authentication
            .send(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },

            // authentication with email required
            .receive(.walletPairing(.approveEmailAuthorization)),
            .receive(.none),
            .do { self.mockMainQueue.advance() },
            .environment { environment in
                // after approval twoFA type should be set to standard
                (environment.loginService as! MockLoginService).twoFAType = .standard
            },
            .do {
                // nothing should happen after 1 second
                self.mockPollingQueue.advance(by: 1)
            },
            .do {
                // polling should happen after 1 more second (2 seconds in total)
                self.mockPollingQueue.advance(by: 1)
            },
            .receive(.walletPairing(.pollWalletIdentifier)),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .receive(.walletPairing(.decryptWalletWithPassword(""))),
            .do { self.mockMainQueue.advance() }
        )
    }

    func test_authenticate_sms_required_should_return_relevant_actions() {
        // set sms as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .sms

        // some preliminery actions
        setupWalletInfoAndSessionToken()

        testStore.assert(
            // authentication
            .send(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },

            // authentication with sms requied
            .receive(.walletPairing(.requestSMSCode)),
            .receive(.twoFA(.resendSMSButtonVisibility(true))) { state in
                state.twoFAState?.isResendSMSButtonVisible = true
            },
            .receive(.twoFA(.twoFACodeFieldVisibility(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
            },
            .receive(.none),
            .do { self.mockMainQueue.advance() }
        )
    }

    func test_authenticate_google_auth_required_should_return_relevant_actions() {
        // set google auth as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .google

        // some preliminery actions
        setupWalletInfoAndSessionToken()

        testStore.assert(
            // authentication
            .send(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },

            // authentication with google auth required
            .receive(.twoFA(.twoFACodeFieldVisibility(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
            }
        )
    }

    func test_authenticate_hardware_key_required_should_return_relevant_actions() {
        // set yubikey as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .yubiKey

        // some preliminery actions
        setupWalletInfoAndSessionToken()

        testStore.assert(
            // authentication
            .send(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },

            // authentication with yubikey required
            .receive(.hardwareKey(.hardwareKeyCodeFieldVisibility(true))) { state in
                state.hardwareKeyState?.isHardwareKeyCodeFieldVisible = true
            }
        )
    }

    func test_authenticate_with_twoFA_should_return_relevant_actions() {
        // set 2FA required (e.g. sms)
        (testStore.environment.loginService as! MockLoginService).twoFAType = .sms

        // some preliminery actions
        setupWalletInfoAndSessionToken()

        testStore.assert(
            // set twoFA field visible
            .send(.twoFA(.twoFACodeFieldVisibility(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
            },
            // authentication
            .send(.walletPairing(.authenticate)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },

            // authentication using 2FA
            .receive(.walletPairing(.authenticateWithTwoFAOrHardwareKey)),
            .receive(.accountLockedErrorVisibility(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.hardwareKey(.incorrectHardwareKeyCodeErrorVisibility(false))) { state in
                state.hardwareKeyState?.isHardwareKeyCodeIncorrect = false
            },
            .receive(.twoFA(.incorrectTwoFACodeErrorVisibility(false))) { state in
                state.twoFAState?.isTwoFACodeIncorrect = false
            },
            .receive(.password(.incorrectPasswordErrorVisibility(false))) { state in
                state.passwordState?.isPasswordIncorrect = false
            },
            .receive(.setTwoFAOrHardwareKeyVerified(true)) { state in
                state.isTwoFACodeOrHardwareKeyVerified = true
            },
            .receive(.twoFA(.twoFACodeFieldVisibility(false))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = false
            },
            .receive(.hardwareKey(.hardwareKeyCodeFieldVisibility(false))) { state in
                state.hardwareKeyState?.isHardwareKeyCodeFieldVisible = false
            },
            .receive(.walletPairing(.decryptWalletWithPassword("")))
        )
    }

    // MARK: - Helpers

    private func setupWalletInfoAndSessionToken() {
        let mockWalletInfo = MockDeviceVerificationService.mockWalletInfo
        testStore.assert(
            .send(.didAppear(walletInfo: mockWalletInfo)) { state in
                state.emailAddress = mockWalletInfo.email
                state.walletGuid = mockWalletInfo.guid
                state.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.setupSessionToken)),
            .do { self.mockMainQueue.advance() },
            .receive(.none)
        )
    }
}
