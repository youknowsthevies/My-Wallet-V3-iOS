// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import TestKit
import ToolKit
import XCTest

final class ReplayNetworkCommunicatorTests: XCTestCase {

    func test() throws {

        let comunicator = try ReplayNetworkCommunicator(
            [
                URLRequest(url: "https://api.blockchain.info/example-request-true"): ["success": true].data(),
                URLRequest(url: "https://api.blockchain.info/example-request-false"): ["success": false].data()
            ]
        )

        let trueResult = comunicator.dataTaskPublisher(
            for: NetworkRequest(endpoint: "https://api.blockchain.info/example-request-true", method: .get)
        )

        try XCTAssertEqual(trueResult.wait().payload, ["success": true].data())

        let falseResult = try comunicator.dataTaskPublisher(
            for: NetworkRequest(endpoint: "https://api.blockchain.info/example-request-false", method: .get)
        )

        try XCTAssertEqual(falseResult.wait().payload, ["success": false].data())

        let errorResult = comunicator.dataTaskPublisher(
            for: NetworkRequest(endpoint: "https://api.blockchain.info/example-request-error", method: .get)
        )

        XCTAssertThrowsError(try errorResult.wait())
    }
}
