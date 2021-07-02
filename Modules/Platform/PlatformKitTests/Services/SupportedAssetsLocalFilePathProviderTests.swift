// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

class SupportedAssetsLocalFilePathProviderTests: XCTestCase {

    var sut: SupportedAssetsLocalFilePathProviderAPI!

    override func setUp() {
        sut = SupportedAssetsLocalFilePathProvider()
    }

    override func tearDown() {
        sut = nil
    }

    func testLocalFileIsPresent() {
        guard let localFile = sut.localERC20Assets else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.contains("local-currencies-erc20.json"))
    }
}
