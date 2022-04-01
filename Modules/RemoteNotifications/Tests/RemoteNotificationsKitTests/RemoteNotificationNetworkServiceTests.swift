// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
@testable import NetworkKitMock
@testable import RemoteNotificationsKit
@testable import RemoteNotificationsKitMock
import UserNotifications
import XCTest

final class RemoteNotificationNetworkServiceTests: XCTestCase {

    private enum Fixture: String {
        case success = "remote-notification-registration-success"
        case failure = "remote-notification-registration-failure"
    }

    var cancellables: Set<AnyCancellable> = []
    var credentialsProvider: MockGuidSharedKeyRepositoryAPI!
    var subject: RemoteNotificationNetworkService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
        credentialsProvider = MockGuidSharedKeyRepositoryAPI()
    }

    override func tearDownWithError() throws {
        subject = nil
        credentialsProvider = nil
        cancellables = []
        try super.tearDownWithError()
    }

    func testHttpCodeOkWithSuccess() {
        let token = "remote-notification-token"
        subject = prepareServiceForHttpCodeOk(with: .success)
        let registerExpectation = expectation(
            description: "Service registered token."
        )
        subject
            .register(
                with: token,
                sharedKeyProvider: credentialsProvider,
                guidProvider: credentialsProvider
            )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    case .finished:
                        break
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

    func testHttpCodeOkWithFailure() {
        let token = "remote-notification-token"
        subject = prepareServiceForHttpCodeOk(with: .failure)
        let registerExpectation = expectation(
            description: "Service registered token failed."
        )
        subject
            .register(
                with: token,
                sharedKeyProvider: credentialsProvider,
                guidProvider: credentialsProvider
            )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .registrationFailure:
                            registerExpectation.fulfill()
                        default:
                            XCTFail("Expected 'registrationFailure'. Got \(error) instead.")
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected token registration to fail. Got success instead.")
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

    private func prepareServiceForHttpCodeOk(with fixture: Fixture) -> RemoteNotificationNetworkService {
        let networkAdapter = NetworkAdapterMock()
        networkAdapter.response = (filename: fixture.rawValue, bundle: .remoteNotificationKitMock)
        return RemoteNotificationNetworkService(
            pushNotificationsUrl: "blockchain.com",
            networkAdapter: networkAdapter
        )
    }
}
