//
//  StringSHA256Tests.swift
//  CommonCryptoKitTests
//
//  Created by Paulo on 23/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import CommonCryptoKit
import Foundation
import XCTest

class ECDHTests: XCTestCase {
    func testSameSharedSecret() throws {
        let priv = "9cd3b16e10bd574fed3743d8e0de0b7b4e6c69f3245ab5a168ef010d22bfefa0"
        let pub = "02a18a98316b5f52596e75bfa5ca9fa9912edd0c989b86b73d41bb64c9c6adb992"
        let result = try ECDH.derive(priv: Data(hex: priv), pub: Data(hex: pub)).get()
        XCTAssertEqual(result.hexValue, "c87e593a1b22bad696489aa7c240356ffc8ff453d4637dc9cd32b4696df93f5c")
    }

    func testDecrypt() throws {
        let secret = "9cd3b16e10bd574fed3743d8e0de0b7b4e6c69f3245ab5a168ef010d22bfefa0"
        let testVector = "83e77704adf28646b602047763a179b5991a5d5d4457658200c84936c71e5e7ffb54a1dcf665d836cb2ce34a471747eb64392e80"
        let result = try ECDH.decrypt(priv: Data(hex: secret), payload: Data(hex: testVector)).get()
        XCTAssertEqual(String(decoding: result, as: UTF8.self), "This is a test sentence!")
    }
}
