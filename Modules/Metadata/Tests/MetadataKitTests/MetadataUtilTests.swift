// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
import XCTest

final class MetadataUtilTests: XCTestCase {

    func testGetMessage() throws {

        let message = "{\"hello\":\"world\"}"
        let expected1 = "eyJoZWxsbyI6IndvcmxkIn0="
        let expected2 = "LxR+2CipfgdIdi4EZgNOKTT+96WbppXnPZZjdZJ2vwCTojlxqRTl6svwqNJRVM2jCcPBxy+7mRTUfGDzy2gViA=="

        let result = try MetadataUtil.message(payload: message.bytes, prevMagicHash: nil).get()
        XCTAssertEqual(expected1, result.toBase64())

        let magic = try MetadataUtil.magic(payload: message.bytes, prevMagicHash: nil).get()

        let nextResult = try MetadataUtil.message(payload: message.bytes, prevMagicHash: magic).get()
        XCTAssertEqual(expected2, nextResult.toBase64())
    }

    func testMagic() throws {

        let message = "{\"hello\":\"world\"}"
        let expected1 = "LxR+2CipfgdIdi4EZgNOKTT+96WbppXnPZZjdZJ2vwA="
        let expected2 = "skkJOHg9L6/1OVztbUohjcvVR3cNdRDZ/OJOUdQI41M="

        let magic = try MetadataUtil.magic(payload: message.bytes, prevMagicHash: nil).get()
        XCTAssertEqual(expected1, magic.toBase64())

        let nextMagic = try MetadataUtil.magic(payload: message.bytes, prevMagicHash: magic).get()
        XCTAssertEqual(expected2, nextMagic.toBase64())
    }
}
