// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import PlatformKit
import RxSwift
import XCTest

class ExchangeAddressFetchingTests: XCTestCase {

    var assets: [CryptoCurrency] {
        [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar,
            .algorand,
            .polkadot,
            .erc20(.aave),
            .erc20(.yearnFinance),
            .erc20(.wdgld),
            .erc20(.pax),
            .erc20(.tether)
        ]
    }

    func testFetchingAddressForAllAssetsForActiveState() {
        for asset in assets {
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

        for asset in assets {
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
