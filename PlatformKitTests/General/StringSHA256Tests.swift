//
//  StringSHA256Tests.swift
//  PlatformKitTests
//
//  Created by Jack on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import PlatformKit

class StringSHA256Tests: XCTestCase {
    func testSha256() {
        XCTAssertEqual("1234567890asdfghjklqwertyuiopzxcvbnm".sha256, "3265e08fe41cb43ce0ee1a324571cfd3ba9e77ac135fca3637d6cc138f6cf8f3")
    }
}
