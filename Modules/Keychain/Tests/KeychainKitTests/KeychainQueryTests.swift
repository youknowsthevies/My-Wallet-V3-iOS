// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import KeychainKit

class KeychainQueryTests: XCTestCase {

    func test_can_build_a_generic_password_query() {
        let genericPasswordQuery = GenericPasswordQuery(service: "a-service")

        let query = genericPasswordQuery.query()

        XCTAssertEqual(
            query[String(kSecClass)] as! String,
            String(kSecClassGenericPassword)
        )

        XCTAssertEqual(
            query[String(kSecAttrService)] as! String,
            "a-service"
        )

        XCTAssertEqual(
            query[String(kSecAttrAccessible)] as! String,
            KeychainPermission.afterFirstUnlock.queryValue as String
        )
    }
}
