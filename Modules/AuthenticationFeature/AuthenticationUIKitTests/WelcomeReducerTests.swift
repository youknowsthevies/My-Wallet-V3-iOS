// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationUIKit
import ComposableArchitecture
import XCTest

final class WelcomeReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        WelcomeState,
        WelcomeState,
        WelcomeAction,
        WelcomeAction,
        WelcomeEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(),
            reducer: welcomeReducer,
            environment: .init(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                deviceVerificationService: MockDeviceVerificationService(),
                buildVersionProvider: { "Test Version" }
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = WelcomeState()
        XCTAssertNotNil(state.emailLoginState)
    }

    func test_start_updates_the_build_version() {
        testStore.send(.start) { state in
            state.buildVersion = "Test Version"
        }
    }

    func test_present_screen_flow_updates_screen_flow() {
        let screenFlows: [WelcomeState.ScreenFlow] = [
            .welcomeScreen,
            .createWalletScreen,
            .emailLoginScreen,
            .recoverWalletScreen
        ]
        screenFlows.forEach { screenFlow in
            testStore.send(.presentScreenFlow(screenFlow)) { state in
                state.screenFlow = screenFlow
            }
        }
    }

    func test_close_email_login_should_reset_state() {
        testStore.send(.emailLogin(.closeButtonTapped)) { state in
            state.screenFlow = .welcomeScreen
            XCTAssertNotNil(state.emailLoginState)
        }
    }
}
