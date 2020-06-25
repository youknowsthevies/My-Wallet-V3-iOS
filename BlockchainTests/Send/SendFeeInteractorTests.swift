//
//  SendFeeInteractorTests.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import XCTest

@testable import Blockchain

// Asset agnostic tests for spendable balance interaction layer
final class SendFeeInteractorTests: XCTestCase {

    private let currencyCode = "USD"
    private let asset = CryptoCurrency.ethereum
    
    private var interactor: SendFeeInteracting {
        let fee = CryptoValue.createFromMajorValue(string: "1", assetType: asset)!
        let feeService = MockSendFeeService(expectedValue: fee)
        
        let fiatExchangeRate = FiatValue.create(amountString: "1", currencyCode: currencyCode)
        let exchangeService = MockPairExchangeService(expectedValue: fiatExchangeRate)
        return SendFeeInteractor(
            feeService: feeService,
            exchangeService: exchangeService
        )
    }
    
    func testFeeCalculationStateIsValue() throws {
        let interactor = self.interactor
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertTrue(state.isValue)
    }
}

