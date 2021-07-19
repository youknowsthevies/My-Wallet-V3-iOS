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
                deviceVerificationService: MockDeviceVerificationService()
                // TODO: create mocks for the other services and use them here to prevent DIKit errors
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
        testStore.send(.didAppear(walletInfo: mockWalletInfo)) { state in
            state.emailAddress = mockWalletInfo.email
            state.walletGuid = mockWalletInfo.guid
            state.emailCode = mockWalletInfo.emailCode
        }
    }

    func test_set_twoFA_verified_should_update_view_state() {
        testStore.assert(
            .send(.setTwoFAOrHardwareKeyVerified(true)) { state in
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
}
