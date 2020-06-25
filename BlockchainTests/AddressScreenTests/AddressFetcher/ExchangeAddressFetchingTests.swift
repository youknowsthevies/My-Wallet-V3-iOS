//
//  ExchangeAddressFetchingTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 23/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import PlatformKit
import RxSwift
import XCTest

class ExchangeAddressFetchingTests: XCTestCase {
    
    func testFetchingAddressForAllAssetsForActiveState() {
        for asset in CryptoCurrency.allCases {
            let fetcher = MockExchangeAddressFetcher(expectedResult: .success(.active))
            do {
                _ = try fetcher.fetchAddress(for: asset).toBlocking().first()
            } catch {
                XCTFail("expected success, got \(error.localizedDescription) instead")
            }
        }
    }
    
    func testFetchingAddressForAllAssetsForInactiveState() {
        let states: [ExchangeAddressFetcher.AddressResponseBody.State] = [
            .pending,
            .blocked
        ]

        for asset in CryptoCurrency.allCases {
            for state in states {
                let fetcher = MockExchangeAddressFetcher(expectedResult: .success(state))
                do {
                    _ = try fetcher.fetchAddress(for: asset).toBlocking().first()
                    XCTFail("expected failure for \(state) account state, got success instead")
                } catch { // Failure is a success
                    XCTAssert(true)
                }
            }
        }
    }
}
