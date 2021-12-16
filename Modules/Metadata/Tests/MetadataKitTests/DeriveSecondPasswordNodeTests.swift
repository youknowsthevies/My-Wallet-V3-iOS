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
    }
}
