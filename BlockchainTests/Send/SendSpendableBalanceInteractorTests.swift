//
//  SendSpendableBalanceInteractorTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import XCTest

@testable import Blockchain
import PlatformKit

// Asset agnostic tests for spendable balance interaction layer
final class SendSpendableBalanceInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    private let asset = CryptoCurrency.ethereum
    private let currencyCode = "USD"
    private lazy var balance = CryptoValue.createFromMajorValue(string: "100", assetType: asset)!
    
    func testSpendableBalanceWhenFeeIsCalculating() throws {
        let interactor = self.interactor(for: asset, balance: balance, feeState: .calculating)
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertTrue(state.isCalculating)
    }
    
    func testSpendableBalanceHigherThanFee() throws {
        let fee = feeValue(by: "1")
        let interactor = self.interactor(for: asset, balance: balance, feeState: .value(fee))
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertEqual(state.value?.base.cryptoValue, try balance - fee.base.cryptoValue!)
    }
    
    func testSpendableBalanceEqualToFee() throws {
        let fee = feeValue(by: "100")
        let interactor = self.interactor(for: asset, balance: balance, feeState: .value(fee))
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertEqual(state.value?.base.cryptoValue, try balance - fee.base.cryptoValue!)
    }
    
    func testSpendableBalanceLowerThanFee() throws {
        let fee = feeValue(by: "101")
        let interactor = self.interactor(for: asset, balance: balance, feeState: .value(fee))
        let state = try interactor.calculationState.toBlocking().first()!
        XCTAssertEqual(state.value?.base.cryptoValue, CryptoValue.zero(currency: asset))
    }
    
    // MARK: - Accessors
    
    private func feeValue(by amount: String) -> MoneyValuePair {
        let fiatFee = FiatValue.create(amountString: amount, currencyCode: currencyCode)
        let cryptoFee = CryptoValue.createFromMajorValue(string: amount, assetType: asset)!
        let fee = MoneyValuePair(base: cryptoFee.moneyValue, quote: fiatFee.moneyValue)
        return fee
    }
    
    private func interactor(for asset: CryptoCurrency,
                            balance: CryptoValue,
                            feeState: MoneyValuePairCalculationState) -> SendSpendableBalanceInteracting {
        let exchangeRate = FiatValue.create(amountString: "1", currencyCode: "USD")
        return SendSpendableBalanceInteractor(
            balanceFetcher: MockAccountBalanceFetcher(expectedBalance: balance.moneyValue),
            feeInteractor: MockSendFeeInteractor(expectedState: feeState),
            exchangeService: MockPairExchangeService(expectedValue: exchangeRate)
        )
    }
}
