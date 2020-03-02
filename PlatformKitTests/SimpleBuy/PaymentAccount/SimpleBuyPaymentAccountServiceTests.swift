//
//  SimpleBuyPaymentAccountServiceTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
@testable import PlatformKit

class SimpleBuyPaymentAccountServiceTests: XCTestCase {
    var disposeBag: DisposeBag!
    var sut: SimpleBuyPaymentAccountService!
    var dataRepository: DataRepositoryMock!
    var client: SimpleBuyPaymentAccountClientAPIMock!
    private var fiatCurrencyService: FiatCurrencySettingsServiceMock!
    private let fiatCurrency = FiatCurrency.GBP
    
    override func setUp() {
        disposeBag = DisposeBag()
        dataRepository = DataRepositoryMock()
        client = SimpleBuyPaymentAccountClientAPIMock()
        fiatCurrencyService = FiatCurrencySettingsServiceMock(
            expectedCurrency: fiatCurrency
        )
        sut = SimpleBuyPaymentAccountService(
            client: client,
            dataRepository: dataRepository,
            authenticationService: NabuAuthenticationServiceMock(),
            fiatCurrencyService: fiatCurrencyService
        )
    }

    override func tearDown() {
        disposeBag = nil
        dataRepository = nil
        client = nil
        sut = nil
    }

    func testSuccessScenario() {
        client.mockResponse = SimpleBuyPaymentAccountResponse.mock(with: .GBP, agent: .fullMock)
        let finishes = expectation(description: "finishes")
        sut
            .paymentAccount(for: .GBP)
            .subscribe(onSuccess: { account in
                finishes.fulfill()
            }, onError: { _ in
                XCTFail("action should not have errored")
            })
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5)
    }

    func testErrorRaisedForInvalidResponse() {
        client.mockResponse = SimpleBuyPaymentAccountResponse.mock(with: .GBP, agent: .emptyMock)
        let fails = expectation(description: "fails")
        sut
            .paymentAccount(for: .GBP)
            .subscribe(onSuccess: { account in
                XCTFail("action should not have succeeded")
            }, onError: { error in
                fails.fulfill()
            })
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5)
    }
}
