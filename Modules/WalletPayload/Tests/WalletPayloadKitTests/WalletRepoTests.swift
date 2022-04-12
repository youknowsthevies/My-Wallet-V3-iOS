// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
import XCTest

class WalletRepoTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    private let initialState = WalletRepoState(
        credentials: WalletCredentials(
            guid: "guid",
            sharedKey: "sharedKey",
            sessionToken: "sessionToken",
            password: "password"
        ),
        properties: WalletProperties(
            syncPubKeys: false,
            language: "en",
            authenticatorType: .standard
        ),
        walletPayload: .empty
    )

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_can_retrieve_state_variables() {
        let walletRepo = WalletRepo(
            initialState: initialState
        )

        XCTAssertEqual(walletRepo.credentials.guid, "guid")
        XCTAssertEqual(walletRepo.credentials.sharedKey, "sharedKey")
    }

    func test_wallet_storage_can_provide_publisher() {
        let walletRepo = WalletRepo(
            initialState: initialState
        )

        var receivedState: WalletRepoState?
        let expectation = expectation(description: "wallet.storage.publisher.expectation")
        walletRepo
            .get()
            .sink(receiveValue: { state in
                receivedState = state
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(receivedState)
        XCTAssertEqual(receivedState!, initialState)
    }

    func test_wallet_storage_can_provide_state_variable_as_publisher() {
        let walletRepo = WalletRepo(
            initialState: initialState
        )

        var receivedValues: [String] = []
        let expectation = expectation(description: "wallet.storage.publisher.expectation")
        expectation.expectedFulfillmentCount = 3
        walletRepo.credentials
            .sink(receiveValue: { credentials in
                receivedValues.append(credentials.guid)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        walletRepo.set(
            keyPath: \.credentials.guid,
            value: "updated-guid"
        )

        let updatedCredentials = WalletCredentials(
            guid: "updated-guid-2",
            sharedKey: "new-sharedKey",
            sessionToken: "new-sessionToken",
            password: "new-password"
        )
        walletRepo.set(
            keyPath: \.credentials,
            value: updatedCredentials
        )

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(receivedValues)
        XCTAssertEqual(receivedValues.count, 3)
        XCTAssertEqual(receivedValues, ["guid", "updated-guid", "updated-guid-2"])
        XCTAssertEqual(walletRepo.credentials, updatedCredentials)
    }

    func test_wallet_storage_can_change_state() {
        let walletRepo = WalletRepo(
            initialState: initialState
        )

        walletRepo.set(keyPath: \.credentials.guid, value: "updated-guid")

        XCTAssertEqual(walletRepo.credentials.guid, "updated-guid")
        XCTAssertEqual(walletRepo.credentials.sharedKey, "sharedKey")
    }

    func test_wallet_storage_can_set_a_new_state() {
        let walletRepo = WalletRepo(
            initialState: initialState
        )

        let updatedState = WalletRepoState(
            credentials: WalletCredentials(
                guid: "new-guid",
                sharedKey: "new-sharedKey",
                sessionToken: "new-sessionToken",
                password: "new-password"
            ),
            properties: WalletProperties(
                syncPubKeys: true,
                language: "en",
                authenticatorType: .standard
            ),
            walletPayload: .empty
        )

        walletRepo.set(value: updatedState)

        XCTAssertEqual(walletRepo.credentials, updatedState.credentials)
        XCTAssertEqual(walletRepo.properties, updatedState.properties)
    }
}
