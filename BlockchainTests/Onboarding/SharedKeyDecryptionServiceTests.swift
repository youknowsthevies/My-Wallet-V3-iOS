//
//  SharedKeyDecryptionServiceTests.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking

@testable import ToolKit
@testable import PlatformKit
@testable import Blockchain


class SharedKeyDecryptionServiceTests: XCTestCase {

    var service: SharedKeyDecryptionService!
    
    override func setUp() {
        super.setUp()
        // Force JS initialization before hand
        _ = WalletManager.shared.fetchJSContext()
        service = SharedKeyDecryptionService(
            jsContextProvider: WalletManager.shared
        )
    }
    
    func testDecryption() throws {
        let key = "password"
        let data = "data"

        /// TODO: Move to a separate encryption service (see `SharedKeyDecryptionService`)
        let encrypted = WalletManager.shared.wallet.encrypt(
            data,
            password: key,
            pbkdf2_iterations: Int32(SharedKeyDecryptionService.Constant.pbkdf2Iterations)
        )!
        
        let pair = KeyDataPair(key: key, data: encrypted)
        
        let decryptedData = try service.decrypt(pair: pair).toBlocking().first()!
        
        XCTAssertEqual(data, decryptedData)
    }
}
