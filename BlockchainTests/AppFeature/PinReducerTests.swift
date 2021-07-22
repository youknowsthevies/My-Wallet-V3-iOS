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
    var mockWallet: MockWallet!
    var settingsApp: MockBlockchainSettingsApp!

    override func setUp() {
        mockWallet = MockWallet()
        settingsApp = MockBlockchainSettingsApp(
            enabledCurrenciesService: MockEnabledCurrenciesService(),
            keychainItemWrapper: MockKeychainItemWrapping(),
            legacyPasswordProvider: MockLegacyPasswordProvider()
        )
        mockWalletManager = WalletManager(
            wallet: mockWallet!,
            appSettings: settingsApp,
            reactiveWallet: MockReactiveWallet()
        )
    }

    func test_verify_initial_state_is_correct() {
        let state = PinCore.State()
        XCTAssertFalse(state.authenticate)
        XCTAssertFalse(state.creating)
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
            state.creating = false
        }

        testStore.send(.create) { state in
            state.creating = true
            state.authenticate = false
        }
    }
}
