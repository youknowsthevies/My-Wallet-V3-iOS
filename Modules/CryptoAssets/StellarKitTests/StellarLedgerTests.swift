//
//  StellarLedgerTests.swift
//  StellarKitTests
//
//  Created by Jack on 02/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxBlocking
import RxSwift
import stellarsdk
import XCTest
@testable import StellarKit

class StellarLedgerServiceTests: XCTestCase {

    var subject: StellarLedgerService!
    var ledgersService: LedgersServiceMock!
    var feeService: CryptoFeeServiceMock<StellarTransactionFee>!
    var configurationService: StellarConfigurationServiceMock!
    var disposables = CompositeDisposable()

    override func setUp() {
        super.setUp()

        disposables = CompositeDisposable()
        feeService = CryptoFeeServiceMock<StellarTransactionFee>()
        ledgersService = LedgersServiceMock()
        configurationService = StellarConfigurationServiceMock()

        subject = StellarLedgerService(
            ledgersServiceProvider: LedgersServiceProviderMock(ledgersService: ledgersService),
            feeService: AnyCryptoFeeService<StellarTransactionFee>(service: feeService)
        )
    }

    override func tearDown() {
        disposables.dispose()
        configurationService = nil
        feeService = nil
        ledgersService = nil
        subject = nil

        super.tearDown()
    }

    func test_returns_correct_fee() {
        let feeIsCorrectExpectation = self.expectation(
            description: "The fee returned by the ledger should be the fee returned by the fee service"
        )
        feeService.underlyingFees = .init(limits: TransactionFeeLimits(min: 111, max: 222), regular: 333, priority: 444)
        let disposable = subject.current
            .subscribe(onNext: { ledger in
                XCTAssertEqual(ledger.baseFeeInStroops, 333)
                feeIsCorrectExpectation.fulfill()
            }, onError: { error in
                XCTFail("this shouldn't error")
            })
        _ = disposables.insert(disposable)

        waitForExpectations(timeout: TimeInterval(5))
    }
}
