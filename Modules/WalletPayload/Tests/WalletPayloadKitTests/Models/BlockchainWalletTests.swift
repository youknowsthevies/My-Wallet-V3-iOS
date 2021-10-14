// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import TestKit
@testable import WalletPayloadKit
import XCTest

class BlockchainWalletTests: XCTestCase {

    let jsonV3 = Fixtures.loadJSONData(filename: "wallet.v3", in: .module)!
    let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    func test_it_should_be_able_to_be_decoded_from_json_version4() throws {
        XCTAssertNoThrow(
            try JSONDecoder().decode(BlockchainWallet.self, from: jsonV4)
        )
    }

    func test_it_should_be_able_to_be_decoded_from_json_version3() throws {
        XCTAssertNoThrow(
            try JSONDecoder().decode(BlockchainWallet.self, from: jsonV3)
        )
    }
}
