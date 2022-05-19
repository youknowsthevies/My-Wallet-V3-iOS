// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import XCTest

class DeepLinkRouteTests: XCTestCase {

    func testInvalidPath() {
        let url = "https://login.blockchain.com/#/open/notasupportedurl"
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNil(route)
    }
}
