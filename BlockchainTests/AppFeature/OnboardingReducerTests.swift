// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit
import XCTest

@testable import Blockchain

class OnboardingReducerTests: XCTestCase {

    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet = MockWallet()
    var settingsApp: MockBlockchainSettingsApp!
    var mockAlertPresenter: MockAlertViewPresenter!

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
        mockAlertPresenter = MockAlertViewPresenter()
    }

    func test_verify_initial_state_is_correct() {
        let state = Onboarding.State()
        XCTAssertNotNil(state.pinState)
    }

    func test_should_authenticate_when_pinIsSet_and_guidSharedKey_are_set() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter
            )
        )

        // given
        settingsApp.guid = "a-guid"
        settingsApp.sharedKey = "a-sharedKey"
        settingsApp.isPinSet = true

        // then
        testStore.assert(
            .send(.start),
            .receive(.pin(.authenticate), { state in
                state.pinState?.authenticate = true
            })
        )
    }

    func test_should_passwordScreen_when_pin_is_not_set() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter
            )
        )

        // given
        settingsApp.guid = "a-guid"
        settingsApp.sharedKey = "a-sharedKey"
        settingsApp.isPinSet = false

        // then
        testStore.assert(
            .send(.start),
            .receive(.passwordScreen)
        )
    }

    func test_should_authenticate_pinIsSet_and_icloud_restoration_exists() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter
            )
        )

        // given
        settingsApp.pinKey = "a-pin-key"
        settingsApp.encryptedPinPassword = "a-encryptedPinPassword"
        settingsApp.isPinSet = true

        // then
        testStore.assert(
            .send(.start),
            .receive(.pin(.authenticate), { state in
                state.pinState?.authenticate = true
            })
        )
    }

    func test_should_passwordScreen_whenPin_not_set_and_icloud_restoration_exists() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter
            )
        )

        // given
        settingsApp.pinKey = "a-pin-key"
        settingsApp.encryptedPinPassword = "a-encryptedPinPassword"
        settingsApp.isPinSet = false

        // then
        testStore.assert(
            .send(.start),
            .receive(.passwordScreen)
        )
    }

    func test_should_show_welcome_screen() {
        let testStore = TestStore(
            initialState: Onboarding.State(),
            reducer: onBoardingReducer,
            environment: Onboarding.Environment(
                blockchainSettings: settingsApp,
                walletManager: mockWalletManager,
                alertPresenter: mockAlertPresenter
            )
        )

        // given
        settingsApp.guid = nil
        settingsApp.sharedKey = nil
        settingsApp.pinKey = nil
        settingsApp.encryptedPinPassword = nil

        // then
        testStore.assert(
            .send(.start),
            .receive(.welcomeScreen)
        )
    }
}
