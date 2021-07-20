// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
@testable import AuthenticationUIKit
import ComposableArchitecture
import Localization
import ToolKit
import XCTest

final class VerifyDeviceReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        VerifyDeviceState,
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(),
            reducer: verifyDeviceReducer,
            environment: .init(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                deviceVerificationService: MockDeviceVerificationService(),
                errorRecorder: NoOpErrorRecorder()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = VerifyDeviceState()
        XCTAssertNotNil(state.credentialsState)
        XCTAssertEqual(state.walletInfo, WalletInfo.empty)
        XCTAssertFalse(state.isCredentialsScreenVisible)
    }

    func test_receive_valid_wallet_deeplink_should_update_wallet_info() {
        testStore.assert(
            .send(.didReceiveWalletInfoDeeplink(MockDeviceVerificationService.validDeeplink)),
            .do { self.mockMainQueue.advance() },
            .receive(.didExtractWalletInfo(MockDeviceVerificationService.mockWalletInfo)) { state in
                state.walletInfo = MockDeviceVerificationService.mockWalletInfo
            },
            .receive(.setCredentialsScreenVisible(true)) { state in
                state.isCredentialsScreenVisible = true
            }
        )
    }

    // TODO: Comment for now (wait until error states design are finalised)
//    func test_receive_invalid_wallet_deeplink_should_show_error() {
//        let invalidDeeplink = URL(string: "https://login.blockchain.com")!
//        testStore.assert(
//            .send(.didReceiveWalletInfoDeeplink(invalidDeeplink)),
//            .do { self.mockMainQueue.advance() },
//            .receive(.verifyDeviceFailureAlert(.show(title: "", message: ""))) { state in
//                state.verifyDeviceFailureAlert = AlertState(
//                    title: TextState(""),
//                    message: TextState(""),
//                    dismissButton: .default(
//                        TextState(LocalizationConstants.okString),
//                        send: .verifyDeviceFailureAlert(.dismiss)
//                    )
//                )
//            }
//        )
//    }
}
