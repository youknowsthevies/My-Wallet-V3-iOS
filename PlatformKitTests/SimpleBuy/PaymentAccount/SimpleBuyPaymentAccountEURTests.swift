//
//  SimpleBuyPaymentAccountEURTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import PlatformKit

class SimpleBuyPaymentAccountEURTests: XCTestCase {
    let sut = SimpleBuyPaymentAccountEUR.self
    
    func testItsStaticCurrencyIsEUR() {
        XCTAssertEqual(sut.currency, .EUR, "currency must be EUR")
    }
    
    func testInitWithEmptyResponse() {
        let mock = SimpleBuyPaymentAccountResponse.mock(with: .EUR, agent: .emptyMock)
        let account = sut.init(response: mock)
        XCTAssertNil(account, "SimpleBuyPaymentAccountEUR initiated with a empty agent mock should be nil")
    }
    
    func testInitWithWrongCurrency() {
        let mock = SimpleBuyPaymentAccountResponse.mock(with: .GBP, agent: .fullMock)
        let account = sut.init(response: mock)
        XCTAssertNil(account, "SimpleBuyPaymentAccountEUR initiated with wrong currency response should be nil")
    }
    
    func testInitWithMinimalResponse() {
        let mock = SimpleBuyPaymentAccountResponse.mock(with: .EUR, agent: .minimumEURMock)
        let account = sut.init(response: mock)
        XCTAssertNotNil(account, "SimpleBuyPaymentAccountEUR initiated with the minimal EUR agent mock should not be nil")
        
        XCTAssertEqual(account!.identifier, mock.id, "its id comes from the response object")
        XCTAssertEqual(account!.state, mock.state, "its state comes from the response object")
        XCTAssertEqual(account!.currency, mock.currency, "its currency comes from the response object")
        
        XCTAssertEqual(account!.bankName, mock.agent.name, "its bankName comes from response.agent")
        XCTAssertEqual(account!.bankCountry, "", "its bankCountry is empty")
        XCTAssertEqual(account!.iban, mock.address, "its iban comes from response.address")
        XCTAssertEqual(account!.bankCode, mock.agent.code, "its bankCode comes from response.agent")
        XCTAssertEqual(account!.recipientName, "", "its recipientName is empty")
    }
    
    func testInitWithIdealResponse() {
        let mock = SimpleBuyPaymentAccountResponse.mock(with: .EUR, agent: .idealEURMock)
        let account = sut.init(response: mock)
        XCTAssertNotNil(account, "SimpleBuyPaymentAccountEUR initiated with the minimal EUR agent mock should not be nil")
        
        XCTAssertEqual(account!.identifier, mock.id, "its id comes from the response object")
        XCTAssertEqual(account!.state, mock.state, "its state comes from the response object")
        XCTAssertEqual(account!.currency, mock.currency, "its currency comes from the response object")
        
        XCTAssertEqual(account!.bankName, mock.agent.name, "its bankName comes from response.agent")
        XCTAssertEqual(account!.bankCountry, mock.agent.country, "its bankCountry comes from response.agent")
        XCTAssertEqual(account!.iban, mock.address, "its iban comes from response.address")
        XCTAssertEqual(account!.bankCode, mock.agent.code, "its bankCode comes from response.agent")
        XCTAssertEqual(account!.recipientName, mock.agent.recipient, "its recipientName comes from response.agent")
    }
    
}
