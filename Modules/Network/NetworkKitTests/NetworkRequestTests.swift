// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit
import XCTest

final class NetworkRequestTests: XCTestCase {

    // MARK: - CustomStringConvertible

    func test_get_request_description_unauthenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .get).with(authenticated: false).build()
        XCTAssertEqual(request.description, "GET https://blockchain.com (unauthenticated)")
    }

    func test_get_request_description_authenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .get).with(authenticated: true).build()
        XCTAssertEqual(request.description, "GET https://blockchain.com (authenticated)")
    }

    func test_post_request_description_unauthenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .post).with(authenticated: false).build()
        XCTAssertEqual(request.description, "POST https://blockchain.com (unauthenticated)")
    }

    func test_post_request_description_authenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .post).with(authenticated: true).build()
        XCTAssertEqual(request.description, "POST https://blockchain.com (authenticated)")
    }
}
