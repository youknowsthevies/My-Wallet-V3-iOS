// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import WalletPayloadKit
import XCTest

class WalletStorageTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    private let initialState = WalletStorageState(
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
        encryptedPayload: "payload",
        userId: "userId",
        lifetimeToken: "lifetimeToken"
    )

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_can_retrieve_state_variables() {
        let walletStorage = WalletStorage(
            initialState: initialState
        )

        XCTAssertEqual(walletStorage.credentials.guid, "guid")
        XCTAssertEqual(walletStorage.credentials.sharedKey, "sharedKey")
    }

    func test_wallet_storage_can_provide_publisher() {
        let walletStorage = WalletStorage(
            initialState: initialState
        )

        var receivedState: WalletStorageState?
        let expectation = expectation(description: "wallet.storage.publisher.expectation")
        walletStorage
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
        let walletStorage = WalletStorage(
            initialState: initialState
        )

        var receivedValues: [String] = []
        let expectation = expectation(description: "wallet.storage.publisher.expectation")
        expectation.expectedFulfillmentCount = 3
        walletStorage.credentials
            .sink(receiveValue: { credentials in
                receivedValues.append(credentials.guid)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        walletStorage.set(
            keyPath: \.credentials.guid,
            value: "updated-guid"
        )

        let updatedCredentials = WalletCredentials(
            guid: "updated-guid-2",
            sharedKey: "new-sharedKey",
            sessionToken: "new-sessionToken",
            password: "new-password"
        )
        walletStorage.set(
            keyPath: \.credentials,
            value: updatedCredentials
        )

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(receivedValues)
        XCTAssertEqual(receivedValues.count, 3)
        XCTAssertEqual(receivedValues, ["guid", "updated-guid", "updated-guid-2"])
        XCTAssertEqual(walletStorage.credentials, updatedCredentials)
    }

    func test_wallet_storage_can_change_state() {
        let walletStorage = WalletStorage(
            initialState: initialState
        )

        walletStorage.set(keyPath: \.credentials.guid, value: "updated-guid")

        XCTAssertEqual(walletStorage.credentials.guid, "updated-guid")
        XCTAssertEqual(walletStorage.credentials.sharedKey, "sharedKey")
    }

    func test_wallet_storage_can_set_a_new_state() {
        let walletStorage = WalletStorage(
            initialState: initialState
        )

        let updatedState = WalletStorageState(
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
            encryptedPayload: "new-payload",
            userId: "new-userId",
            lifetimeToken: "new-lifetimeToken"
        )

        walletStorage.set(value: updatedState)

        XCTAssertEqual(walletStorage.credentials, updatedState.credentials)
        XCTAssertEqual(walletStorage.properties, updatedState.properties)
    }
}
