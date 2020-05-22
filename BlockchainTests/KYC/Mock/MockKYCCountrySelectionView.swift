//
//  MockKYCCountrySelectionView.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

@testable import PlatformKit
@testable import Blockchain

class MockKYCCountrySelectionView: KYCCountrySelectionView {
    var didCallContinueKycFlow: XCTestExpectation?
    var didCallStartPartnerExchangeFlow: XCTestExpectation?
    var didCallShowExchangeNotAvailable: XCTestExpectation?

    func continueKycFlow(country: CountryData) {
        didCallContinueKycFlow?.fulfill()
    }

    func startPartnerExchangeFlow(country: CountryData) {
        didCallStartPartnerExchangeFlow?.fulfill()
    }

    func showExchangeNotAvailable(country: CountryData) {
        didCallShowExchangeNotAvailable?.fulfill()
    }
}
