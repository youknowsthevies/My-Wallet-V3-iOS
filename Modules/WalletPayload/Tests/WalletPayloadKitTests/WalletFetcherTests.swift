// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import MetadataKitMock
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletFetcherTests: XCTestCase {

    let jsonV4 = Fixtures.loadJSONData(filename: "wallet-wrapper-v4", in: .module)!

    private var cancellables: Set<AnyCancellable>!
    private var walletRepo: WalletRepo!

    override func setUp() {
        super.setUp()
        walletRepo = WalletRepo(initialState: .empty)
        cancellables = []
    }

    func test_wallet_fetcher_is_able_to_fetch_using_password() throws {
        let dispatchQueue = DispatchQueue(label: "wallet.fetcher.op-queue")
        let payloadCrypto = PayloadCrypto(cryptor: AESCryptor())
        let walletHolder = WalletHolder()
        let decoder = WalletDecoder()
        let metadataService = MetadataServiceMock()
        let notificationCenterSpy = NotificationCenterSpy()
        let upgrader = WalletUpgrader(workflows: [])
        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder.createWallet,
            upgrader: upgrader,
            metadata: metadataService,
            notificationCenter: notificationCenterSpy
        )
        let walletFetcher = WalletFetcher(
            walletRepo: walletRepo,
            payloadCrypto: payloadCrypto,
            walletLogic: walletLogic,
            operationsQueue: dispatchQueue
        )

        let encryptedPayload = String(data: jsonV4, encoding: .utf8)!
        let walletPayload = WalletPayload(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            authType: 0,
            language: "en",
            shouldSyncPubKeys: false,
            time: Date(),
            payloadChecksum: "",
            payload: try? WalletPayloadWrapper(string: encryptedPayload)
        )
        walletRepo.set(
            keyPath: \.walletPayload,
            value: walletPayload
        )
        var receivedValue: WalletFetchedContext?
        let expectedValue = WalletFetchedContext(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            sharedKey: "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888",
            passwordPartHash: "561e1"
        )
        var error: Error?
        let expectation = expectation(description: "wallet-fetching-expectation")

        metadataService.initializeValue = .just(MetadataState.mock)

        walletFetcher.fetch(using: "misura12!")
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failureError):
                    error = failureError
                }
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)

        XCTAssertTrue(walletHolder.walletState.value!.isInitialised)
        XCTAssertEqual(receivedValue, expectedValue)
        XCTAssertNil(error)

        // Ensure we send both notification
        XCTAssertTrue(notificationCenterSpy.postNotificationCalled)
        XCTAssertEqual(
            notificationCenterSpy.postNotifications,
            [
                Notification(name: .walletInitialized),
                Notification(name: .walletMetadataLoaded)
            ]
        )
    }
}

class NotificationCenterSpy: NotificationCenter {

    var postNotifications: [Notification] = []
    var postNotificationCalled = false

    override func post(_ notification: Notification) {
        postNotifications.append(notification)
        postNotificationCalled = true
    }
}
