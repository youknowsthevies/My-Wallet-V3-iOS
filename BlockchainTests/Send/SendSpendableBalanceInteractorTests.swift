// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import XCTest

@testable import Blockchain
import PlatformKit

// Asset agnostic tests for spendable balance interaction layer
final class SendSpendableBalanceInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    private let asset = CryptoCurrency.ethereum
    private let currency = FiatCurrency.USD
    private lazy var balance = CryptoValue.create(major: "100", currency: asset)!
    
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
        let fiatFee = FiatValue.create(major: amount, currency: currency)!
        let cryptoFee = CryptoValue.create(major: amount, currency: asset)!
        let fee = MoneyValuePair(base: cryptoFee.moneyValue, quote: fiatFee.moneyValue)
        return fee
    }
    
    private func interactor(for asset: CryptoCurrency,
                            balance: CryptoValue,
                            feeState: MoneyValuePairCalculationState) -> SendSpendableBalanceInteracting {
        let exchangeRate = FiatValue.create(major: "1", currency: .USD)!
        return SendSpendableBalanceInteractor(
            balanceFetcher: MockAccountBalanceFetcher(expectedBalance: balance.moneyValue),
            feeInteractor: MockSendFeeInteractor(expectedState: feeState),
            exchangeService: MockPairExchangeService(expectedValue: exchangeRate)
        )
    }
}
