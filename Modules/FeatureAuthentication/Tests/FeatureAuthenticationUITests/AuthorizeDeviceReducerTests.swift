// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
import XCTest

@testable import FeatureAuthenticationMock

final class AuthorizeDeviceReducerTests: XCTest {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var mockDeviceVerificationService: DeviceVerificationServiceAPI!
    private var testStore: TestStore<
        AuthorizeDeviceState,
        AuthorizeDeviceState,
        AuthorizeDeviceAction,
        AuthorizeDeviceAction,
        AuthorizeDeviceEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        mockDeviceVerificationService = MockDeviceVerificationService()
        testStore = TestStore(
            initialState: .init(
                loginRequestInfo: LoginRequestInfo(
                    sessionId: "",
                    base64Str: "",
                    details: DeviceVerificationDetails(originLocation: "", originIP: "", originBrowser: ""),
                    timestamp: Date()
                )
            ),
            reducer: authorizeDeviceReducer,
            environment: .init(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                deviceVerificationService: mockDeviceVerificationService
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        mockDeviceVerificationService = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_handle_authorization_should_set_result() {
        testStore.assert(
            .send(.handleAuthorization(true)),
            .receive(.showAuthorizationResult(.success(.noValue))) { state in
                state.authorizationResult = .success
            },
            .do { self.mockMainQueue.advance() }
        )
        testStore.assert(
            .send(.handleAuthorization(false)),
            .receive(.showAuthorizationResult(.failure(.requestDenied))) { state in
                state.authorizationResult = .requestDenied
            },
            .do { self.mockMainQueue.advance() }
        )
    }
}
