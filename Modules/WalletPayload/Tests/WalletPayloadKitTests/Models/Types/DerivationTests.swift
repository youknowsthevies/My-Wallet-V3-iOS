// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class DerivationTests: XCTestCase {

    // swiftlint:disable line_length
    func test_can_create_correct_derivation_for_legacy_type() {
        let masterSeedHex = getHDWallet(
            from: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        ).successData!.seed.toHexString

        let key = deriveAccountKey(
            at: 0,
            masterNode: masterSeedHex,
            type: .legacy
        )

        XCTAssertEqual(
            key.xpriv,
            "xprv9xpXFhFpqdQK3TmytPBqXtGSwS3DLjojFhTGht8gwAAii8py5X6pxeBnQ6ehJiyJ6nDjWGJfZ95WxByFXVkDxHXrqu53WCRGypk2ttuqncb"
        )

        XCTAssertEqual(
            key.xpub,
            "xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYJVVhhawA7d4R5WSWGFNbi8Aw6ZRc1brxMyWMzG3DSSSSoekkudhUd9yLb6qx39T9nMdj"
        )
    }

    func test_can_create_correct_derivation_for_segwit_type() {
        let masterSeedHex = getHDWallet(
            from: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        ).successData!.seed.toHexString

        let key = deriveAccountKey(
            at: 0,
            masterNode: masterSeedHex,
            type: .segwit
        )

        XCTAssertEqual(
            key.xpriv,
            "xprv9ybY78BftS5UGANki6oSifuQEjkpyAC8ZmBvBNTshQnCBcxnefjHS7buPMkkqhcRzmoGZ5bokx7GuyDAiktd5HemohAU4wV1ZPMDRmLpBMm"
        )

        XCTAssertEqual(
            key.xpub,
            "xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V"
        )
    }
    // swiftlint:enable line_length
}
