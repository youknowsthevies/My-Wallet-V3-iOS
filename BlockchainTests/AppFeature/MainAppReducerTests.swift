// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit
import WalletPayloadKit
import XCTest

@testable import Blockchain

class MainAppReducerTests: XCTestCase {
    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet! = MockWallet()
    var mockReactiveWallet = MockReactiveWallet()
    var settingsApp: MockBlockchainSettingsApp!
    var mockCredentialsStore: CredentialsStoreAPIMock!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockWalletUpgradeService: MockWalletUpgradeService!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer:MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockCoincore: MockCoincore!
    var mockFeatureConfigurator: MockFeatureConfigurator!

    var testStore: TestStore<
        CoreAppState,
        CoreAppState,
        CoreAppAction,
        CoreAppAction,
        CoreAppEnvironment
    >!

    override func setUp() {
        settingsApp = MockBlockchainSettingsApp(
            enabledCurrenciesService: MockEnabledCurrenciesService(),
            keychainItemWrapper: MockKeychainItemWrapping(),
            legacyPasswordProvider: MockLegacyPasswordProvider()
        )
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: settingsApp,
            reactiveWallet: mockReactiveWallet
        )
        mockCredentialsStore = CredentialsStoreAPIMock()
        mockAlertPresenter = MockAlertViewPresenter()
        mockWalletUpgradeService = MockWalletUpgradeService()
        mockExchangeAccountRepository = MockExchangeAccountRepository()
        mockRemoteNotificationAuthorizer = MockRemoteNotificationAuthorizer(
            expectedAuthorizationStatus: UNAuthorizationStatus.authorized,
            authorizationRequestExpectedStatus: .success(())
        )
        mockRemoteNotificationServiceContainer = MockRemoteNotificationServiceContainer(
            authorizer: mockRemoteNotificationAuthorizer
        )
        mockCoincore = MockCoincore()
        mockFeatureConfigurator = MockFeatureConfigurator()

        testStore = TestStore(
            initialState: CoreAppState(),
            reducer: mainAppReducer,
            environment: CoreAppEnvironment(
                walletManager: mockWalletManager,
                appFeatureConfigurator: mockFeatureConfigurator,
                blockchainSettings: settingsApp,
                credentialsStore: mockCredentialsStore,
                alertPresenter: mockAlertPresenter,
                walletUpgradeService: mockWalletUpgradeService,
                exchangeRepository: mockExchangeAccountRepository,
                remoteNotificationServiceContainer: mockRemoteNotificationServiceContainer,
                coincore: mockCoincore
            )
        )
    }

    func test_verify_initial_state_is_correct() {
        let state = CoreAppState()
        XCTAssertNil(state.window)
        XCTAssertNotNil(state.onboarding)
        XCTAssertNil(state.loggedIn)
    }

    func test_syncPinKeyWithICloud() {
        // given
        settingsApp.mockIsPairedWithWallet = true

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: settingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        settingsApp.mockIsPairedWithWallet = false
        settingsApp.guid = "a"
        settingsApp.sharedKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: settingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        settingsApp.mockIsPairedWithWallet = false
        settingsApp.encryptedPinPassword = "a"
        settingsApp.pinKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: settingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        settingsApp.mockIsPairedWithWallet = false
        settingsApp.pinKey = nil
        settingsApp.encryptedPinPassword = nil
        settingsApp.guid = nil
        settingsApp.sharedKey = nil

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: settingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertTrue(mockCredentialsStore.synchronizeCalled)
        XCTAssertTrue(mockCredentialsStore.expectedPinDataCalled)
    }

    func test_sending_start_should_correct_outputs() {
        let window = UIWindow()

        testStore.send(.start(window: window)) { state in
            state.onboarding = Onboarding.State()
            state.loggedIn = nil
            state.window = window
        }
        XCTAssertTrue(mockFeatureConfigurator.initializeCalled)
    }

    func test_sending_success_authentication_from_pin() {
        testStore.send(.onboarding(.pin(.authenticated(.success(true)))))
        mockReactiveWallet.mockState.on(.next(.initialized))
        // need to send completed event to stop the stream from being active
        mockReactiveWallet.mockState.on(.completed)

        testStore.receive(.walletInitialized)
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.proceedToLoggedIn) { state in
                state.loggedIn = LoggedIn.State()
                state.onboarding = nil
            }
        testStore.receive(.loggedIn(.start(window: nil)))
    }

    func test_sending_walletInitialized_should_check_if_wallet_upgrade_is_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(true))
        testStore.send(.walletInitialized)
        testStore.receive(.walletNeedsUpgrade(true))
    }

    func test_sending_walletInitialized_should_proceed_to_logged_in_when_no_upgrade_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(false))
        testStore.send(.walletInitialized)
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.proceedToLoggedIn) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        testStore.receive(.loggedIn(.start(window: nil)))
    }
}
