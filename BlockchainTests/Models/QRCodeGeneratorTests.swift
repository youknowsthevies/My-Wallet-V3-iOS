//
//  QRCodeGeneratorTests.swift
//  BlockchainTests
//
//  Created by Jack on 02/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
@testable import Blockchain
import PlatformKit
import PlatformUIKit
import XCTest

class QRCodeGeneratorTests: XCTestCase {
    
    var subject: QRCodeGenerator!

    override func setUp() {
        super.setUp()
        subject = QRCodeGenerator()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_qrcode_from_string() {
        let testString = "xpub<ADDRESS>"
        let image = subject.createQRImage(fromString: testString)
        XCTAssertNotNil(image)
    }
    
    func test_qrcode_from_address() {
        let address = "<ADDRESS>"
        let amount = "12.34"
        let asset: LegacyAssetType = .bitcoin
        let metadata = BitcoinURLPayload(address: address, amount: amount, includeScheme: false)
        var qrCode: QRCodeAPI? = QRCode(metadata: metadata)
        
        let image = subject.qrImage(
            fromAddress: address,
            amount: amount,
            asset: asset,
            includeScheme: false
        )
        XCTAssertNotNil(image)
    }
}
