// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
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
    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockCredentialsStore: CredentialsStoreAPIMock!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockWalletUpgradeService: MockWalletUpgradeService!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer:MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockCoincore: MockCoincore!
    var mockFeatureConfigurator: MockFeatureConfigurator!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var mockSiftService: MockSiftService!
    var onboardingSettings: MockOnboardingSettings!

    var testStore: TestStore<
        CoreAppState,
        CoreAppState,
        CoreAppAction,
        CoreAppAction,
        CoreAppEnvironment
    >!

    override func setUp() {
        mockSettingsApp = MockBlockchainSettingsApp(
            enabledCurrenciesService: MockEnabledCurrenciesService(),
            keychainItemWrapper: MockKeychainItemWrapping(),
            legacyPasswordProvider: MockLegacyPasswordProvider()
        )
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: mockSettingsApp,
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
        mockAnalyticsRecorder = MockAnalyticsRecorder()
        mockSiftService = MockSiftService()
        onboardingSettings = MockOnboardingSettings()

        testStore = TestStore(
            initialState: CoreAppState(),
            reducer: mainAppReducer,
            environment: CoreAppEnvironment(
                walletManager: mockWalletManager,
                appFeatureConfigurator: mockFeatureConfigurator,
                blockchainSettings: mockSettingsApp,
                credentialsStore: mockCredentialsStore,
                alertPresenter: mockAlertPresenter,
                walletUpgradeService: mockWalletUpgradeService,
                exchangeRepository: mockExchangeAccountRepository,
                remoteNotificationServiceContainer: mockRemoteNotificationServiceContainer,
                coincore: mockCoincore,
                sharedContainer: SharedContainerUserDefaults(),
                analyticsRecorder: mockAnalyticsRecorder,
                siftService: mockSiftService,
                onboardingSettings: onboardingSettings
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
        mockSettingsApp.mockIsPairedWithWallet = true

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: mockSettingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.mockIsPairedWithWallet = false
        mockSettingsApp.guid = "a"
        mockSettingsApp.sharedKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: mockSettingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.mockIsPairedWithWallet = false
        mockSettingsApp.encryptedPinPassword = "a"
        mockSettingsApp.pinKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: mockSettingsApp,
                             credentialsStore: mockCredentialsStore)

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.mockIsPairedWithWallet = false
        mockSettingsApp.pinKey = nil
        mockSettingsApp.encryptedPinPassword = nil
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil

        // method is implementing fireAndForget
        syncPinKeyWithICloud(blockchainSettings: mockSettingsApp,
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

    func test_verify_didDecryptWallet_action_updates_appSettings() {
        testStore.send(
            .didDecryptWallet(.init(guid: "a", sharedKey: "b", passwordPartHash: "c"))
        )
        XCTAssertNotNil(testStore.environment.blockchainSettings.guid)
        XCTAssertEqual(testStore.environment.blockchainSettings.guid, "a")

        XCTAssertNotNil(testStore.environment.blockchainSettings.sharedKey)
        XCTAssertEqual(testStore.environment.blockchainSettings.sharedKey, "b")
    }

    func test_sending_success_authentication_from_password_required_screen() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = false
        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.passwordScreen = .init()
        }

        // password screen should start
        testStore.receive(.onboarding(.passwordScreen(.start)))

        // when authenticating 
        testStore.send(.onboarding(.passwordScreen(.authenticate("password"))))

        testStore.receive(.authenticate("password"))
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash)

        XCTAssertTrue(mockWallet.fetchCalled)
    }

    func test_sending_success_authentication_from_pin() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true
        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordScreen = nil
        }

        // password screen should start
        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
        }

        // when authenticating
        testStore.send(.onboarding(.pin(.handleAuthentication("password"))))

        testStore.receive(.authenticate("password"))
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash)

        XCTAssertTrue(mockWallet.fetchCalled)
    }

    func test_sending_logout_should_perform_cleanup_and_display_password_screen() {
        testStore.send(.proceedToLoggedIn) { state in
            state.loggedIn = .init()
            state.onboarding = nil
        }

        testStore.receive(.loggedIn(.start(window: nil)))

        testStore.send(.loggedIn(.logout)) { state in
            state.loggedIn = nil
            state.onboarding = .init(pinState: nil, walletUpgradeState: nil, passwordScreen: .init())
        }

        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        XCTAssertNotNil(mockAnalyticsRecorder.recordEventCalled.event)
        XCTAssertEqual(mockAnalyticsRecorder.recordEventCalled.event!.name,
                       AnalyticsEvents.New.Navigation.signedOut.name)

        XCTAssertTrue(mockSiftService.removeUserIdCalled)
        XCTAssertTrue(mockSettingsApp.resetCalled)
        XCTAssertTrue(onboardingSettings.resetCalled)

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_logout_should_perform_cleanup_and_pin_screen() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true
        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.passwordScreen = nil
        }

        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
            state.onboarding?.passwordScreen = nil
        }

        testStore.send(.onboarding(.pin(.logout))) { state in
            state.loggedIn = nil
            state.onboarding = .init(pinState: nil, walletUpgradeState: nil, passwordScreen: .init())
        }

        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        XCTAssertNotNil(mockAnalyticsRecorder.recordEventCalled.event)
        XCTAssertEqual(mockAnalyticsRecorder.recordEventCalled.event!.name,
                       AnalyticsEvents.New.Navigation.signedOut.name)

        XCTAssertTrue(mockSiftService.removeUserIdCalled)
        XCTAssertTrue(mockSettingsApp.resetCalled)
        XCTAssertTrue(onboardingSettings.resetCalled)

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_walletInitialized_should_check_if_wallet_upgrade_is_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(true))

        testStore.send(.walletInitialized)
        testStore.receive(.walletNeedsUpgrade(true)) { state in
            state.onboarding?.pinState = nil
            state.onboarding?.walletUpgradeState = WalletUpgrade.State()
            state.loggedIn = nil
        }

        testStore.receive(.onboarding(.walletUpgrade(.begin)))

        testStore.send(.onboarding(.walletUpgrade(.completed)))
        testStore.receive(.proceedToLoggedIn) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        testStore.receive(.loggedIn(.start(window: nil)))
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

    func test_clearPinIfNeeded_correctly_clears_pin() {
        // given a hashed password
        mockSettingsApp.passwordPartHash = "a-hash"

        // 1. when the same password hash is used
        clearPinIfNeeded(for: "a-hash", appSettings: mockSettingsApp)

        // 1. then it should not clear the saved pin
        XCTAssertFalse(mockSettingsApp.clearPinCalled)

        // 2. when a different password hash is used (on password change)
        clearPinIfNeeded(for: "a-diff-hash", appSettings: mockSettingsApp)

        // 1. then it should clear the saved pin
        XCTAssertTrue(mockSettingsApp.clearPinCalled)
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
            code: AuthenticationError.ErrorCode.errorDecryptingWallet,
            description: LocalizationConstants.Authentication.errorDecryptingWallet
        )

        XCTAssertEqual(CoreAppAction.decryptionFailure(expectedError), action)
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
            code: AuthenticationError.ErrorCode.invalidSharedKey,
            description: LocalizationConstants.Authentication.invalidSharedKey
        )

        XCTAssertEqual(CoreAppAction.decryptionFailure(expectedError), action)
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
        XCTAssertEqual(CoreAppAction.didDecryptWallet(decryption), action)
    }
}
