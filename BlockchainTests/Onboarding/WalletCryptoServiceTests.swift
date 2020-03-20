//
//  WalletCryptoServiceTests.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import Blockchain
import ToolKit
import PlatformKit

class WalletCryptoServiceTests: XCTestCase {

    var walletManager: WalletManager!
    var service: WalletCryptoService!
    
    override func setUp() {
        super.setUp()
        // Force JS initialization before hand
        walletManager = WalletManager.shared
        _ = walletManager.fetchJSContext()
        service = WalletCryptoService(jsContextProvider: walletManager)
    }
    
    func testDecryption() {
        let key = "keykeykeykeykey"
        let data = "datadatadatadatadata"
        let pbkdf2Iterations: Int = 100
        do {
            let encrypted = try service
                .encrypt(pair: KeyDataPair(key: key, data: data), pbkdf2Iterations: pbkdf2Iterations)
                .toBlocking()
                .first()
            guard let encryptedData = encrypted else {
                XCTFail("encryptedData is nil")
                return
            }
            let decryptedData = try service
                .decrypt(pair: KeyDataPair(key: key, data: encryptedData), pbkdf2Iterations: pbkdf2Iterations)
                .toBlocking()
                .first()
            XCTAssertEqual(data, decryptedData)
        } catch let error {
            XCTFail("Decryption failed with error: \(error.localizedDescription)")
        }
    }
}
