//
//  ERC20AssetAccountDetailsServiceTests.swift
//  ERC20KitTests
//
//  Created by Jack on 17/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import ERC20Kit
@testable import EthereumKit
import PlatformKit
import RxSwift
import RxTest
import XCTest

class ERC20AssetAccountDetailsServiceTests: XCTestCase {

    var subject: ERC20AssetAccountDetailsService<PaxToken>!
    var scheduler: TestScheduler!
    var bridge: ERC20EthereumWalletBridgeMock!
    var accountClient: ERC20AccountAPIClientMock!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        bridge = ERC20EthereumWalletBridgeMock()
        accountClient = ERC20AccountAPIClientMock()
        subject = ERC20AssetAccountDetailsService<PaxToken>(
            with: bridge,
            service: ERC20BalanceService(with: bridge, accountClient: accountClient)
        )
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        bridge = nil
        accountClient = nil
        subject = nil

        super.tearDown()
    }

    func test_fetch_asset_account_details() {
        // Arrange
        let accountDetailsObservable = subject
            .accountDetails(for: "IOS-3217")
            .asObservable()

        // Act
        let result: TestableObserver<ERC20AssetAccountDetails> = scheduler
            .start { accountDetailsObservable }

        // Assert
        let expectedEvents: [Recorded<Event<ERC20AssetAccountDetails>>] = Recorded.events(
            .next(
                200,
                ERC20AssetAccountDetails(
                    account: ERC20AssetAccount(
                        walletIndex: 0,
                        accountAddress: "0x0000000000000000000000000000000000000000",
                        name: "My \(CryptoCurrency.pax.name) Wallet"
                    ),
                    balance: CryptoValue.pax(major: "2.0")!
                )
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
