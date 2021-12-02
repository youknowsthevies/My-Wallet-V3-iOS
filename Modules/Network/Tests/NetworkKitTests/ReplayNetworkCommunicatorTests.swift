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
                URLRequest(url: "https://api.blockchain.info/example-request-true").json(): ["success": true].data(),
                URLRequest(url: "https://api.blockchain.info/example-request-false").json(): ["success": false].data()
            ]
        )

        let trueResult = comunicator.dataTaskPublisher(
            for: NetworkRequest(endpoint: "https://api.blockchain.info/example-request-true", method: .get)
        )

        try XCTAssertEqual(trueResult.wait().payload, ["success": true].data())

        let falseResult = comunicator.dataTaskPublisher(
            for: NetworkRequest(endpoint: "https://api.blockchain.info/example-request-false", method: .get)
        )

        try XCTAssertEqual(falseResult.wait().payload, ["success": false].data())

        let errorResult = comunicator.dataTaskPublisher(
            for: NetworkRequest(endpoint: "https://api.blockchain.info/example-request-error", method: .get)
        )

        XCTAssertThrowsError(try errorResult.wait())
    }
}

extension URLRequest {
    func json() -> Self {
        var copy = self
        copy.addValue("application/json", forHTTPHeaderField: "Accept")
        return copy
    }
}
