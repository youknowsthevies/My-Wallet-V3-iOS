//
//  SimpleBuyPaymentAccountPatcherTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import BuySellKit

class SimpleBuyPaymentAccountPatcherTests: XCTestCase {
    var sut: SimpleBuyPaymentAccountPatcher!

    override func setUp() {
        sut = SimpleBuyPaymentAccountPatcher()
    }

    func testIdealEURAccountIsNotPatched() {
        let eurAccount = SimpleBuyPaymentAccountEUR(identifier: "identifier",
                                                    state: .active,
                                                    bankName: "bankName",
                                                    bankCountry: "bankCountry",
                                                    iban: "iban",
                                                    bankCode: SimpleBuyPaymentAccountPatcher.targetBankCode,
                                                    recipientName: "recipientName")

        let result = sut.patch(eurAccount, recipientName: "patched") as! SimpleBuyPaymentAccountEUR

        XCTAssertEqual(result, eurAccount, "Complete EUR Account should not be patched")
    }

    func testMinimumEURAccountIsNotPatched() {
        let eurAccount = SimpleBuyPaymentAccountEUR(identifier: "identifier",
                                                    state: .active,
                                                    bankName: "bankName",
                                                    bankCountry: "",
                                                    iban: "iban",
                                                    bankCode: SimpleBuyPaymentAccountPatcher.targetBankCode,
                                                    recipientName: "")

        let result = sut.patch(eurAccount, recipientName: "patched") as! SimpleBuyPaymentAccountEUR

        XCTAssertNotEqual(result, eurAccount, "EUR Account should be patched")
        XCTAssertEqual(result.recipientName, "patched", "recipientName should be the given one")
        XCTAssertEqual(result.bankCountry, SimpleBuyPaymentAccountPatcher.targetBankCountry, "bankCountry should be the targetBankCountry")
    }

}
