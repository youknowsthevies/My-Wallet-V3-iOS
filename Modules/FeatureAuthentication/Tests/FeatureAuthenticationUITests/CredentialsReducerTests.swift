// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
import Localization
import ToolKit
import XCTest

// Mocks
@testable import AnalyticsKitMock
@testable import FeatureAuthenticationMock
@testable import ToolKitMock

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
                sessionTokenService: MockSessionTokenService(),
                deviceVerificationService: MockDeviceVerificationService(),
                emailAuthorizationService: MockEmailAuthorizationService(),
                smsService: MockSMSService(),
                loginService: MockLoginService(),
                errorRecorder: NoOpErrorRecorder(),
                externalAppOpener: MockExternalAppOpener(),
                featureFlagsService: MockFeatureFlagsService(),
                analyticsRecorder: MockAnalyticsRecorder()
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
        XCTAssertNotNil(state.walletPairingState)
        XCTAssertNotNil(state.passwordState)
        XCTAssertNil(state.twoFAState)
        XCTAssertNil(state.seedPhraseState)
        XCTAssertNil(state.hardwareKeyState)
        XCTAssertFalse(state.isManualPairing)
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isTroubleLoggingInScreenVisible)
        XCTAssertFalse(state.isWalletIdentifierIncorrect)
        XCTAssertFalse(state.isTwoFactorOTPVerified)
        XCTAssertFalse(state.isAccountLocked)
    }

    func test_did_appear_should_setup_wallet_info() {
        let mockWalletInfo = MockDeviceVerificationService.mockWalletInfo
        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(false))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: false)))
        )
    }

    func test_wallet_identifier_fallback_did_appear_should_setup_guid_if_present() {
        let mockWalletGuid = MockDeviceVerificationService.mockWalletInfo.guid
        testStore.assert(
            .send(.didAppear(context: .walletIdentifier(guid: mockWalletGuid))) { state in
                state.walletPairingState.walletGuid = mockWalletGuid
            }
        )
    }

    func test_manual_screen_did_appear_should_setup_session_token() {
        testStore.assert(
            .send(.didAppear(context: .manualPairing)) { state in
                state.walletPairingState.emailAddress = "not available on manual pairing"
                state.isManualPairing = true
            },
            .receive(.walletPairing(.setupSessionToken)),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didSetupSessionToken(.success(.noValue))))
        )
    }

    // MARK: - Wallet Pairing Actions

    func test_authenticate_success_should_update_view_state_and_decrypt_password() {
        /*
         Use Case: Authentication flow without any 2FA
         1. Setup walletInfo
         2. Send didAppear with wallet info context
         3. Approve email authorization should ocurr
         4. Should received a success from email auth
         5. Sending authenticate with an empty password
         6. Reset error states (account locked or password error, for any previous errors)
         7. Decrypt wallet with the password from user
         */

        let has2FAEnabled = false
        let mockWalletInfo = MockDeviceVerificationService.mockWalletInfo
        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: false))),
            // authentication without 2FA
            .send(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.decryptWalletWithPassword(""))) { state in
                state.isLoading = true
            }
        )
    }

    func test_authenticate_email_required_should_return_relevant_actions() throws {
        #warning("skipped as this is manual pairing - needs investigation")
        try XCTSkipIf(true)
        /*
         Use Case: Authentication flow with auto-authorized email approval
         1. Setup walletInfo
         2. Reset error states (account locked or password error, for any previous errors)
         3. When authenticate request sent, received an error saying email authorization required
         4. Auto-approve email authorization, the 2FA type will be set to standard
         5. Conduct polling every 2 seconds, check if GUID has been set remotely
         6. Authenticate again, clear error states again, and proceed to wallet decryption with pw
         */

        // set email authorization as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .email

        // some preliminery actions
        let has2FAEnabled = false
        let mockWalletInfo = MockDeviceVerificationService.mockWalletInfo

        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: false))),
            .do { self.mockMainQueue.advance() },
            // authentication
            .send(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            .do { self.mockMainQueue.advance() },
            // authentication with email required
            .receive(.walletPairing(.authenticateDidFail(.twoFactorOTPRequired(.email)))),
            .receive(.walletPairing(.none)),
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
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.pollWalletIdentifier)),
            .receive(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            .receive(.walletPairing(.decryptWalletWithPassword(""))) { state in
                state.isLoading = true
            },
            .do { self.mockMainQueue.advance() }
        )
    }

    func test_authenticate_sms_required_should_return_relevant_actions() {
        /*
         Use Case: Authentication flow with SMS as 2FA
         1. Setup walletInfo
         2. Reset error states (account locked or password error, for any previous errors)
         3. When authenticate request sent, received an error saying SMS required
         4. Request an SMS code for user
         5. Show the resend SMS button and 2FA field
         */

        // set sms as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .sms

        // some preliminery actions
        let has2FAEnabled = true
        let mockWalletInfo = WalletInfo(guid: "guid", email: "email@email.com", emailCode: "a-code", twoFAType: .sms)

        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: true))),
            .receive(.walletPairing(.startPolling)),
            .receive(.walletPairing(.pollWalletIdentifier)),
            // authentication
            .receive(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            // authentication with sms required
            .receive(.walletPairing(.authenticateDidFail(.twoFactorOTPRequired(.sms)))) { state in
                state.twoFAState = .init(
                    twoFAType: .sms
                )
            },
            .receive(.walletPairing(.handleSMS)),
            .receive(.twoFA(.showResendSMSButton(true))) { state in
                state.twoFAState?.isResendSMSButtonVisible = true
            },
            .receive(.twoFA(.showTwoFACodeField(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
                state.isLoading = false
            },
            .receive(
                .alert(
                    .show(
                        title: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SMSCode.Success.title,
                        message: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SMSCode.Success.message
                    )
                )
            ) { state in
                state.credentialsFailureAlert = AlertState(
                    title: TextState(
                        verbatim: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SMSCode.Success.title
                    ),
                    message: TextState(
                        verbatim: LocalizationConstants.FeatureAuthentication.EmailLogin.Alerts.SMSCode.Success.message
                    ),
                    dismissButton: .default(
                        TextState(LocalizationConstants.okString),
                        action: .send(.alert(.dismiss))
                    )
                )
            },
            .do { self.mockMainQueue.advance() }
        )
    }

    func test_authenticate_google_auth_required_should_return_relevant_actions() {
        /*
         Use Case: Authentication flow with google authenticator as 2FA
         1. Setup walletInfo
         2. Reset error states (account locked or password error, for any previous errors)
         3. When authenticate request sent, received an error saying google authenticator required
         4. Show the 2FA Field
         */

        // set google auth as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .google

        // some preliminery actions
        // some preliminery actions
        let has2FAEnabled = true
        let mockWalletInfo = WalletInfo(
            guid: "guid",
            email: "email@email.com",
            emailCode: "a-code",
            twoFAType: .google
        )

        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: true))),
            .receive(.walletPairing(.startPolling)),
            .receive(.walletPairing(.pollWalletIdentifier)),
            // authentication
            .receive(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            // authentication with google auth required
            .receive(.walletPairing(.authenticateDidFail(.twoFactorOTPRequired(.google)))) { state in
                state.twoFAState = .init(
                    twoFAType: .google
                )
            },
            .receive(.twoFA(.showTwoFACodeField(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
                state.isLoading = false
            }
        )
    }

    func test_authenticate_hardware_key_required_should_return_relevant_actions() {
        /*
         Use Case: Authentication flow with hardware key as 2FA
         1. Setup walletInfo
         2. Reset error states (account locked or password error, for any previous errors)
         3. When authenticate request sent, received an error saying yubikey required
         4. Show the Hardware Key Field
         */

        // set yubikey as default twoFA type
        (testStore.environment.loginService as! MockLoginService).twoFAType = .yubiKey

        // some preliminery actions
        let has2FAEnabled = true
        let mockWalletInfo = WalletInfo(
            guid: "guid",
            email: "email@email.com",
            emailCode: "a-code",
            twoFAType: .yubiKey
        )

        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: true))),
            .receive(.walletPairing(.startPolling)),
            .receive(.walletPairing(.pollWalletIdentifier)),
            // authentication
            .receive(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            // authentication with google auth required
            .receive(.walletPairing(.authenticateDidFail(.twoFactorOTPRequired(.yubiKey)))) { state in
                state.hardwareKeyState = .init(
                    hardwareKeyCode: "",
                    isHardwareKeyCodeFieldVisible: false,
                    isHardwareKeyCodeIncorrect: false
                )
            },
            .receive(.hardwareKey(.showHardwareKeyCodeField(true))) { state in
                state.hardwareKeyState?.isHardwareKeyCodeFieldVisible = true
                state.isLoading = false
            }
        )
    }

    func test_authenticate_with_twoFA_should_return_relevant_actions() {
        /*
         Use Case: Authentication flow with google auth as 2FA
         1. Authenticate with 2FA, clear 2FA error states
         2. Set 2FA verified on success
         3. Proceed to wallet decryption with password
         */

        // set 2FA required (e.g. sms) and initialise twoFA state
        (testStore.environment.loginService as! MockLoginService).twoFAType = .google

        let has2FAEnabled = true
        let mockWalletInfo = WalletInfo(
            guid: "guid",
            email: "email@email.com",
            emailCode: "a-code",
            twoFAType: .google
        )

        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: true))),
            .receive(.walletPairing(.startPolling)),
            .receive(.walletPairing(.pollWalletIdentifier)),
            .receive(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            // authentication using 2FA
            .receive(.walletPairing(.authenticateDidFail(.twoFactorOTPRequired(.google)))) { state in
                state.twoFAState = .init(
                    twoFAType: .google
                )
            },
            .receive(.twoFA(.showTwoFACodeField(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
                state.isLoading = false
            },
            .send(.walletPairing(.authenticateWithTwoFactorOTP(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            .receive(.twoFA(.showIncorrectTwoFACodeError(.none))) { state in
                state.twoFAState?.twoFACodeIncorrectContext = .none
                state.twoFAState?.isTwoFACodeIncorrect = false
            },
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.twoFactorOTPDidVerified)) { state in
                state.isTwoFactorOTPVerified = true
                state.isLoading = false
            },
            .receive(.walletPairing(.decryptWalletWithPassword(""))) { state in
                state.isLoading = true
            }
        )
    }

    func test_authenticate_with_twoFA_wrong_code_error() {
        // set 2FA required (e.g. google)
        (testStore.environment.loginService as! MockLoginService).twoFAType = .google

        // set 2FA error type
        let mockAttemptsLeft = 4
        (testStore.environment.loginService as! MockLoginService)
            .twoFAServiceError = .twoFAWalletServiceError(.wrongCode(attemptsLeft: mockAttemptsLeft))

        let has2FAEnabled = true
        let mockWalletInfo = WalletInfo(
            guid: "guid",
            email: "email@email.com",
            emailCode: "a-code",
            twoFAType: .google
        )

        testStore.assert(
            .send(.didAppear(context: .walletInfo(mockWalletInfo))) { state in
                state.walletPairingState.emailAddress = mockWalletInfo.email!
                state.walletPairingState.walletGuid = mockWalletInfo.guid
                state.walletPairingState.emailCode = mockWalletInfo.emailCode
            },
            .receive(.walletPairing(.approveEmailAuthorization(has2FAEnabled))),
            .do { self.mockMainQueue.advance() },
            .receive(.walletPairing(.didApproveEmailAuthorization(.success(.noValue), has2FAEnabled: true))),
            .receive(.walletPairing(.startPolling)),
            .receive(.walletPairing(.pollWalletIdentifier)),
            .receive(.walletPairing(.authenticate(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            // authentication using 2FA
            .receive(.walletPairing(.authenticateDidFail(.twoFactorOTPRequired(.google)))) { state in
                state.twoFAState = .init(
                    twoFAType: .google
                )
            },
            .receive(.twoFA(.showTwoFACodeField(true))) { state in
                state.twoFAState?.isTwoFACodeFieldVisible = true
                state.isLoading = false
            },
            .send(.walletPairing(.authenticateWithTwoFactorOTP(""))) { state in
                state.isLoading = true
            },
            .receive(.showAccountLockedError(false)) { state in
                state.isAccountLocked = false
            },
            .receive(.password(.showIncorrectPasswordError(false))) { state in
                state.passwordState.isPasswordIncorrect = false
            },
            .receive(.twoFA(.showIncorrectTwoFACodeError(.none))) { state in
                state.twoFAState?.twoFACodeIncorrectContext = .none
                state.twoFAState?.isTwoFACodeIncorrect = false
            },
            .do { self.mockMainQueue.advance() },
            .receive(
                .walletPairing(
                    .authenticateWithTwoFactorOTPDidFail(
                        .twoFAWalletServiceError(
                            .wrongCode(attemptsLeft: mockAttemptsLeft)
                        )
                    )
                )
            ),
            .receive(.twoFA(.didChangeTwoFACodeAttemptsLeft(mockAttemptsLeft))) { state in
                state.twoFAState?.twoFACodeAttemptsLeft = mockAttemptsLeft
            },
            .receive(.twoFA(.showIncorrectTwoFACodeError(.incorrect))) { state in
                state.twoFAState?.twoFACodeIncorrectContext = .incorrect
                state.twoFAState?.isTwoFACodeIncorrect = true
                state.isLoading = false
            }
        )
    }
}
