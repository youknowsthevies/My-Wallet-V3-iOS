// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
import XCTest

final class DeriveSecondPasswordNodeTests: XCTestCase {

    func test_deriveSecondPasswordNode() throws {

        let envionment = TestEnvironment()

        let credentials = envionment.credentials

        let expectedSecondPasswordNode = envionment.secondPasswordNode

        let secondPasswordNodeResult = deriveSecondPasswordNode(
            credentials: credentials
        )

        let secondPasswordNode = try secondPasswordNodeResult.get()
        XCTAssertEqual(secondPasswordNode, expectedSecondPasswordNode)

        let metadataNode = secondPasswordNode.metadataNode
        XCTAssertEqual(
            metadataNode.address,
            "12TMDMri1VSjbBw8WJvHmFpvpxzTJe7EhU"
        )
        XCTAssertEqual(
            metadataNode.node.raw.hex,
            "cf01864ede33b4fc2d36e737ba59467e7ee3938536c7837b75f9fb887643ed9a"
        )
        XCTAssertEqual(
            metadataNode.encryptionKey.hex,
            "cf01864ede33b4fc2d36e737ba59467e7ee3938536c7837b75f9fb887643ed9a"
        )
        XCTAssertNil(metadataNode.unpaddedEncryptionKey)
        XCTAssertEqual(metadataNode.type, .root)
    }
}
