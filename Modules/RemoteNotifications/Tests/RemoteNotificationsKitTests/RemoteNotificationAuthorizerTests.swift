// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AnalyticsKit
@testable import AnalyticsKitMock
import Combine
@testable import RemoteNotificationsKit
@testable import RemoteNotificationsKitMock
import TestKit
import UserNotifications
import XCTest

final class RemoteNotificationAuthorizerTests: XCTestCase {

    // MARK: - Test Authorization Request

    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = []
        try super.tearDownWithError()
    }

    func testSuccessfulAuthorization() {
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .notDetermined,
            expectedAuthorizationResult: .success(true)
        )
        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            analyticsRecorder: analyticsProvider,
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )
        let registerExpectation = expectation(
            description: "Service registered token."
        )
        authorizer
            .requestAuthorizationIfNeeded()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        XCTAssertTrue(registry.isRegistered)
                    }
                },
                receiveValue: { [registerExpectation] _ in
                    registerExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    func testFailedAuthorizationAfterDenyingPermissions() {
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .notDetermined,
            expectedAuthorizationResult: .failure(MockError.unknown)
        )
        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            analyticsRecorder: analyticsProvider,
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )
        let registerExpectation = expectation(
            description: "Service registered token."
        )
        authorizer
            .requestAuthorizationIfNeeded()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        registerExpectation.fulfill()
                        XCTAssertFalse(registry.isRegistered)
                    case .finished:
                        XCTFail("Expected error. Got success instead.")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected error. Got success instead.")
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    func testFailedAuthorizationWhenPermissionIsAlreadyDetermined() {
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .authorized,
            expectedAuthorizationResult: .success(true)
        )
        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            analyticsRecorder: analyticsProvider,
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )

        let registerExpectation = expectation(
            description: "Service registered token."
        )
        authorizer
            .requestAuthorizationIfNeeded()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .statusWasAlreadyDetermined:
                            registerExpectation.fulfill()
                            XCTAssertFalse(registry.isRegistered)
                        default:
                            XCTFail("Expected 'statusWasAlreadyDetermined'. Got \(error) instead.")
                        }
                    case .finished:
                        XCTFail("Expected error. Got success instead.")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected error. Got success instead.")
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    // MARK: - Test Registration If Already Authorized

    func testRegistrationSuccessfulForRemoteNotificationsIfAuthorized() {
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .authorized,
            expectedAuthorizationResult: .success(true)
        )
        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            analyticsRecorder: analyticsProvider,
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )

        let registerExpectation = expectation(
            description: "Service registered token."
        )
        authorizer
            .registerForRemoteNotificationsIfAuthorized()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        XCTAssertTrue(registry.isRegistered)
                    }
                },
                receiveValue: { [registerExpectation] _ in
                    registerExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    func testRegistrationFailureForRemoteNotificationsIfNotAuthorized() {
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .notDetermined,
            expectedAuthorizationResult: .success(true)
        )
        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            analyticsRecorder: analyticsProvider,
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )

        let registerExpectation = expectation(
            description: "Service registered token."
        )
        authorizer
            .registerForRemoteNotificationsIfAuthorized()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .unauthorizedStatus:
                            registerExpectation.fulfill()
                            XCTAssertFalse(registry.isRegistered)
                        default:
                            XCTFail("Expected 'unauthorizedStatus'. Got \(error) instead.")
                        }
                    case .finished:
                        XCTFail("Expected error. Got success instead.")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected error. Got success instead.")
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }
}
