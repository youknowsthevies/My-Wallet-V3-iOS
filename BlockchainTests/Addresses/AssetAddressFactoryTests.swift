//
//  AssetAddressFactoryTests.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinCashKit
import BitcoinKit
@testable import Blockchain
import ERC20Kit
import EthereumKit
import XCTest

class AssetAddressFactoryTests: XCTestCase {

    func testBitcoinAddressCorrectlyConstructed() {
        let address = AssetAddressFactory.create(fromAddressString: "test", assetType: .bitcoin)
        XCTAssertTrue(address is BitcoinAssetAddress)
    }

    func testEtherAddressCorrectlyConstructed() {
        let address = AssetAddressFactory.create(fromAddressString: "test", assetType: .ethereum)
        XCTAssertTrue(address is EthereumAddress)
    }

    func testBitcoinCashAddressCorrectlyConstructed() {
        let address = AssetAddressFactory.create(fromAddressString: "test", assetType: .bitcoinCash)
        XCTAssertTrue(address is BitcoinCashAssetAddress)
    }
}
