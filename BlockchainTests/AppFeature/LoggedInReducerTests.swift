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

class LoggedInReducerTests: XCTestCase {
    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet! = MockWallet()
    var mockReactiveWallet = MockReactiveWallet()
    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer:MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockCoincore: MockCoincore!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var onboardingSettings: MockOnboardingSettings!
    var mockAppDeeplinkHandler: MockAppDeeplinkHandler!
    var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    var mockDeepLinkRouter: MockDeepLinkRouter!
    var mockInternalFeatureFlagService: InternalFeatureFlagServiceMock!
    var fiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceMock!

    var testStore: TestStore<
        LoggedIn.State,
        LoggedIn.State,
        LoggedIn.Action,
        LoggedIn.Action,
        LoggedIn.Environment
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
        mockAlertPresenter = MockAlertViewPresenter()
        mockExchangeAccountRepository = MockExchangeAccountRepository()
        mockRemoteNotificationAuthorizer = MockRemoteNotificationAuthorizer(
            expectedAuthorizationStatus: UNAuthorizationStatus.authorized,
            authorizationRequestExpectedStatus: .success(())
        )
        mockRemoteNotificationServiceContainer = MockRemoteNotificationServiceContainer(
            authorizer: mockRemoteNotificationAuthorizer
        )
        mockCoincore = MockCoincore()
        mockAnalyticsRecorder = MockAnalyticsRecorder()
        onboardingSettings = MockOnboardingSettings()
        mockAppDeeplinkHandler = MockAppDeeplinkHandler()
        mockMainQueue = DispatchQueue.test
        mockDeepLinkRouter = MockDeepLinkRouter()
        mockInternalFeatureFlagService = InternalFeatureFlagServiceMock()
        fiatCurrencySettingsServiceMock = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)

        testStore = TestStore(
            initialState: LoggedIn.State(),
            reducer: loggedInReducer,
            environment: LoggedIn.Environment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                analyticsRecorder: mockAnalyticsRecorder,
                loadingViewPresenter: LoadingViewPresenter(),
                exchangeRepository: mockExchangeAccountRepository,
                remoteNotificationTokenSender: mockRemoteNotificationServiceContainer.tokenSender,
                remoteNotificationAuthorizer: mockRemoteNotificationServiceContainer.authorizer,
                walletManager: mockWalletManager,
                coincore: mockCoincore,
                appSettings: mockSettingsApp,
                deeplinkRouter: mockDeepLinkRouter,
                internalFeatureService: mockInternalFeatureFlagService,
                fiatCurrencySettingsService: fiatCurrencySettingsServiceMock
            )
        )
    }

    func test_verify_initial_state_is_correct() {
        let state = LoggedIn.State()
        XCTAssertNil(state.displayWalletAlertContent)
        XCTAssertFalse(state.reloadAfterMultiAddressResponse)
        XCTAssertFalse(state.reloadAfterSymbolChanged)
    }

    func test_verify_start_action_observers_symbol_changes() {
        testStore.send(.start(.none))

        mockSettingsApp.symbolLocal = true

        testStore.receive(.symbolChanged) { state in
            state.reloadAfterSymbolChanged = true
        }

        testStore.receive(.symbolChangedHandled) { state in
            state.reloadAfterSymbolChanged = false
        }
    }

    func test_verify_sending_wallet_accountInfoAndExchangeRates_updates_the_state() {
        testStore.send(.start(.none))

        testStore.send(.wallet(.accountInfoAndExchangeRates)) { state in
            state.reloadAfterMultiAddressResponse = true
        }

        testStore.receive(.wallet(.accountInfoAndExchangeRatesHandled)) { state in
            state.reloadAfterMultiAddressResponse = false
        }
    }

    func test_verify_sending_wallet_handleWalletBackup() {
        testStore.send(.start(.none))

        testStore.send(.wallet(.handleWalletBackup))

        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)
    }

    func test_verify_sending_wallet_handleFailToLoadHistory() {
        testStore.send(.start(.none))

        // when sending an non nil error
        testStore.send(.wallet(.handleFailToLoadHistory(nil))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
        }

        // when sending an non nil error
        let errorMessage = "this is an error message"
        testStore.send(.wallet(.handleFailToLoadHistory(errorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.balancesGeneric
            )
        }
    }
}
