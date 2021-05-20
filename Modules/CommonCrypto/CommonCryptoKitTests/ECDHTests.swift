// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import XCTest

class ECDHTests: XCTestCase {
    let privateKeyData = Data(hexString: "63a2dfd3ed1a4a8365b1df0437f1860ab7b8de73afdcc1e0aebf1d4c64d4e7c5")!
    let publicKeyData = Data(hexString: "0204a157928751500c12388d8995b7914b32901979be499602638e6133b64746f9")!
    let sharedKeyData = Data(hexString: "6b00840abb1cac475da02b453ab413309cad1b957c76d8e5e8b2bb3a1f1c4417")!

    func testECDHDerivation() throws {
        let result = (try? ECDH.derive(priv: privateKeyData, pub: publicKeyData).get().hexString) ?? ""
        XCTAssertEqual(sharedKeyData.hexString, result)
    }

    func testPublicKeyFromPrivate() throws {
        let walletcore = try ECDH.publicFromPrivate(priv: privateKeyData).get()
        XCTAssertEqual(walletcore.hexString, "02e280656c9e0ae6cfa7ca319a33eac7e0b1b94b811f50a5d2bb89a52a89810558")
    }
}
