// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
@testable import MetadataHDWalletKit
@testable import MetadataKit
import XCTest

final class PrivateKeyTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {

        try super.tearDownWithError()
    }

    func test_deriveKey() throws {

        // swiftlint:disable line_length
        let expectedMetadataNode = try PrivateKey
            .bitcoinKeyFromXPriv(
                xpriv: "xprv9uvPCc4bEjZEaAAxnva4d9gnUGPssAVsT8DfnGuLVdtD9TeQfFtfySYD7P1cBAUZSNXnT52zxxmpx4rs2pzCJxu64gpwzUdu33HEzzjbHty"
            )
            .get()

        let testEnvironment = TestEnvironment()

        let masterKey = try PrivateKey
            .bitcoinKeyFromXPriv(
                xpriv: testEnvironment.masterKeyXPrv
            )
            .get()

        let path: HDKeyPath = try .init(.hardened(510742))

        let key = masterKey.derive(at: path)

        XCTAssertEqual(key, expectedMetadataNode)
    }
}
