// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit
import XCTest

@testable import Blockchain

class PinReducerTests: XCTestCase {

    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet = MockWallet()
    var settingsApp: MockBlockchainSettingsApp!

    override func setUp() {
        settingsApp = MockBlockchainSettingsApp(
            enabledCurrenciesService: MockEnabledCurrenciesService(),
            keychainItemWrapper: MockKeychainItemWrapping(),
            legacyPasswordProvider: MockLegacyPasswordProvider()
        )
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: settingsApp,
            reactiveWallet: MockReactiveWallet()
        )
    }

    func test_verify_initial_state_is_correct() {
        let state = PinCore.State()
        XCTAssertFalse(state.authenticate)
        XCTAssertFalse(state.creating)
        XCTAssertFalse(state.changing)
    }

    func test_verify_state_is_changed_correctly_per_action() {
        let testStore = TestStore(
            initialState: PinCore.State(),
            reducer: pinReducer,
            environment: PinCore.Environment(
                walletManager: mockWalletManager,
                appSettings: settingsApp,
                alertPresenter: MockAlertViewPresenter()
            )
        )

        testStore.send(.authenticate) { state in
            state.authenticate = true
            state.changing = false
            state.creating = false
        }

        testStore.send(.change) { state in
            state.changing = true
            state.authenticate = false
            state.creating = false
        }

        testStore.send(.create) { state in
            state.creating = true
            state.changing = false
            state.authenticate = false
        }
    }

    func test_verify_didDecryptWallet_action_updates_appSettings() {
        let testStore = TestStore(
            initialState: PinCore.State(),
            reducer: pinReducer,
            environment: PinCore.Environment(
                walletManager: mockWalletManager,
                appSettings: settingsApp,
                alertPresenter: MockAlertViewPresenter()
            )
        )

        testStore.send(
            .didDecryptWallet(.init(guid: "a", sharedKey: "b", passwordPartHash: "c"))
        )
        XCTAssertNotNil(testStore.environment.appSettings.guid)
        XCTAssertEqual(testStore.environment.appSettings.guid, "a")

        XCTAssertNotNil(testStore.environment.appSettings.sharedKey)
        XCTAssertEqual(testStore.environment.appSettings.sharedKey, "b")
    }

    func test_clearPinIfNeeded_correctly_clears_pin() {
        // given a hashed password
        settingsApp.passwordPartHash = "a-hash"

        // 1. when the same password hash is used
        clearPinIfNeeded(for: "a-hash", appSettings: settingsApp)

        // 1. then it should not clear the saved pin
        XCTAssertFalse(settingsApp.clearPinCalled)

        // 2. when a different password hash is used (on password change)
        clearPinIfNeeded(for: "a-diff-hash", appSettings: settingsApp)

        // 1. then it should clear the saved pin
        XCTAssertTrue(settingsApp.clearPinCalled)
    }

    func test_wallet_decryption_outputs_decryption_failure_on_invalid_guid() {
        // note: the count of a guid and shared key should equal to 36
        // given a non valid guid
        let decryption = WalletDecryption(
            guid: "a",
            sharedKey: "b",
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        let expectedError = AuthenticationError(
            code: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue,
            description: LocalizationConstants.Authentication.errorDecryptingWallet
        )

        XCTAssertEqual(PinCore.Action.decryptionFailure(expectedError), action)
    }

    func test_wallet_decryption_outputs_failure_on_invalid_sharedKey() {
        // note: the count of a guid and shared key should equal to 36
        // given a non valid sharedKey
        let guid = String(repeating: "a", count: 36)
        let decryption = WalletDecryption(
            guid: guid,
            sharedKey: "b",
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        let expectedError = AuthenticationError(
            code: AuthenticationError.ErrorCode.invalidSharedKey.rawValue,
            description: LocalizationConstants.Authentication.invalidSharedKey
        )

        XCTAssertEqual(PinCore.Action.decryptionFailure(expectedError), action)
    }

    func test_wallet_decryption_outputs_success_on_valid_creds() {
        // note: the count of a guid and shared key should equal to 36
        // given a valid guid
        let guid = String(repeating: "a", count: 36)
        let sharedKey = String(repeating: "b", count: 36)
        let decryption = WalletDecryption(
            guid: guid,
            sharedKey: sharedKey,
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        XCTAssertEqual(PinCore.Action.didDecryptWallet(decryption), action)
    }
}
