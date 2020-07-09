//
//  BlockchainAPI+URLSuffixTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import BitcoinKit
import NetworkKit
import PlatformKit
import XCTest

class BlockchainAPIURLSuffixTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Bitcoin

    func testSuffixURLWithValidBitcoinAddress() {
        let btcAddress = BitcoinAssetAddress(publicKey: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA")
        let url = BlockchainAPI.shared.assetInfoURL(for: btcAddress)
        let expected = "https://blockchain.info/address/\(btcAddress.publicKey)?format=json"
        XCTAssertNotNil(url, "Expected the url to be \(expected), but got nil.")
    }

    // MARK: - Bitcoin Cash

    func testSuffixURLWithValidBitcoinCashAddress() {
        let bchAddress = BitcoinCashAssetAddress(publicKey: "qqzhunu9f7p39e8kgchr628z9wsdxq0c5ua3yf4kzr")
        let url = BlockchainAPI.shared.assetInfoURL(for: bchAddress)
        let expected = "https://api.blockchain.info/bch/multiaddr?active=\(bchAddress.publicKey)"
        XCTAssertNotNil(url, "Expected the url to be \(expected), but got nil.")
    }
}
